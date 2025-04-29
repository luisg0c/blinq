import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Serviço para operações com Firestore
class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger logger = AppLogger('FirestoreService');
  
  // Referências de coleções
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get accountsCollection => _firestore.collection('accounts');
  CollectionReference get transactionsCollection => _firestore.collection('transactions');
  
  /// Cria um documento com ID automático
  Future<DocumentReference> addDocument(
    CollectionReference collection,
    Map<String, dynamic> data,
  ) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await collection.add(data);
      logger.info('Documento criado: ${docRef.id}');
      return docRef;
    } catch (e, stackTrace) {
      logger.error('Erro ao criar documento', e, stackTrace);
      rethrow;
    }
  }
  
  /// Cria ou atualiza um documento com ID específico
  Future<void> setDocument(
    CollectionReference collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      if (!merge) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      
      await collection.doc(docId).set(data, SetOptions(merge: merge));
      logger.info('Documento ${merge ? 'atualizado' : 'criado'}: $docId');
    } catch (e, stackTrace) {
      logger.error('Erro ao ${merge ? 'atualizar' : 'criar'} documento', e, stackTrace);
      rethrow;
    }
  }
  
  /// Atualiza campos específicos de um documento
  Future<void> updateDocument(
    CollectionReference collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await collection.doc(docId).update(data);
      logger.info('Documento atualizado: $docId');
    } catch (e, stackTrace) {
      logger.error('Erro ao atualizar documento', e, stackTrace);
      rethrow;
    }
  }
  
  /// Obtém um documento por ID
  Future<DocumentSnapshot?> getDocument(
    CollectionReference collection,
    String docId,
  ) async {
    try {
      final docSnapshot = await collection.doc(docId).get();
      
      if (!docSnapshot.exists) {
        logger.warn('Documento não encontrado: $docId');
        return null;
      }
      
      return docSnapshot;
    } catch (e, stackTrace) {
      logger.error('Erro ao buscar documento', e, stackTrace);
      rethrow;
    }
  }
  
  /// Exclui um documento
  Future<void> deleteDocument(
    CollectionReference collection,
    String docId,
  ) async {
    try {
      await collection.doc(docId).delete();
      logger.info('Documento excluído: $docId');
    } catch (e, stackTrace) {
      logger.error('Erro ao excluir documento', e, stackTrace);
      rethrow;
    }
  }
  
  /// Busca documentos com filtros
  Future<QuerySnapshot> queryDocuments(
    CollectionReference collection, {
    List<List<dynamic>> filters = const [],
    List<List<dynamic>> orderBy = const [],
    int? limit,
  }) async {
    try {
      Query query = collection;
      
      // Aplicar filtros
      for (final filter in filters) {
        if (filter.length == 3) {
          query = query.where(
            filter[0] as String,
            isEqualTo: filter[1] == '==' ? filter[2] : null,
            isNotEqualTo: filter[1] == '!=' ? filter[2] : null,
            isLessThan: filter[1] == '<' ? filter[2] : null,
            isLessThanOrEqualTo: filter[1] == '<=' ? filter[2] : null,
            isGreaterThan: filter[1] == '>' ? filter[2] : null,
            isGreaterThanOrEqualTo: filter[1] == '>=' ? filter[2] : null,
            arrayContains: filter[1] == 'array-contains' ? filter[2] : null,
          );
        }
      }
      
      // Aplicar ordenação
      for (final order in orderBy) {
        if (order.length == 2) {
          query = query.orderBy(
            order[0] as String,
            descending: order[1] == 'desc',
          );
        }
      }
      
      // Aplicar limite
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final querySnapshot = await query.get();
      logger.info('Consulta retornou ${querySnapshot.docs.length} documentos');
      return querySnapshot;
    } catch (e, stackTrace) {
      logger.error('Erro ao consultar documentos', e, stackTrace);
      rethrow;
    }
  }
  
  /// Cria um stream para um documento específico
  Stream<DocumentSnapshot> documentStream(
    CollectionReference collection,
    String docId,
  ) {
    return collection.doc(docId).snapshots();
  }
  
  /// Cria um stream para uma consulta
  Stream<QuerySnapshot> queryStream(
    CollectionReference collection, {
    List<List<dynamic>> filters = const [],
    List<List<dynamic>> orderBy = const [],
    int? limit,
  }) {
    Query query = collection;
    
    // Aplicar filtros
    for (final filter in filters) {
      if (filter.length == 3) {
        query = query.where(
          filter[0] as String,
          isEqualTo: filter[1] == '==' ? filter[2] : null,
          isNotEqualTo: filter[1] == '!=' ? filter[2] : null,
          isLessThan: filter[1] == '<' ? filter[2] : null,
          isLessThanOrEqualTo: filter[1] == '<=' ? filter[2] : null,
          isGreaterThan: filter[1] == '>' ? filter[2] : null,
          isGreaterThanOrEqualTo: filter[1] == '>=' ? filter[2] : null,
          arrayContains: filter[1] == 'array-contains' ? filter[2] : null,
        );
      }
    }
    
    // Aplicar ordenação
    for (final order in orderBy) {
      if (order.length == 2) {
        query = query.orderBy(
          order[0] as String,
          descending: order[1] == 'desc',
        );
      }
    }
    
    // Aplicar limite
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots();
  }
  
  /// Executa uma transação atômica
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e, stackTrace) {
      logger.error('Erro na transação', e, stackTrace);
      rethrow;
    }
  }
  
  /// Executa operações em lote
  Future<void> executeBatch(void Function(WriteBatch batch) batchHandler) async {
    try {
      final batch = _firestore.batch();
      batchHandler(batch);
      await batch.commit();
      logger.info('Operações em lote executadas com sucesso');
    } catch (e, stackTrace) {
      logger.error('Erro nas operações em lote', e, stackTrace);
      rethrow;
    }
  }
}