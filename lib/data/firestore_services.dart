import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  String collection;

  late CollectionReference _collectionReference;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Inicializamos la referencia en el constructor
  FirestoreService({required this.collection}) {
    _collectionReference = FirebaseFirestore.instance.collection(collection);
  }

  // Método para obtener pedidos filtrados por userId y storeId
  Future<List<QueryDocumentSnapshot>> obtenerPedidosPorUsuarioYTienda(
      String userId, String storeId) async {
    QuerySnapshot snapshot = await _collectionReference
        .where('userId', isEqualTo: userId)
        .where('storeId', isEqualTo: storeId)
        .get();

    return snapshot.docs;
  }

  // Método para obtener anuncios pendientes como un stream
  Stream<QuerySnapshot> getAllEventPostStream() {
    return _collectionReference
        .where('approved', isEqualTo: true)
        .where('active', isEqualTo: true)
        .where('rejected', isEqualTo: false)
        .snapshots();
  }

  // Método para obtener anuncios pendientes como un stream
  Stream<QuerySnapshot> getPendingAdvertisementsStream() {
    return _collectionReference
        .where('approved', isEqualTo: false)
        .where('rejected', isEqualTo: false)
        .snapshots();
  }

  // Método para obtener anuncios rechazados como un stream
  Stream<QuerySnapshot> getRejectedAdvertisementsStream() {
    return _collectionReference.where('rejected', isEqualTo: true).snapshots();
  }

  // Method to update a document in Firestore
  Future<void> updateFirestore(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(id).update(data);
    } catch (e) {
      print("Error updating document: $e");
      throw e;
    }
  }

  // Method to add a new document to Firestore
  Future<void> addFirestore(Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).add(data);
    } catch (e) {
      print("Error adding document: $e");
      throw e;
    }
  }

  // Method to delete a document from Firestore
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection(collection).doc(id).delete();
    } catch (e) {
      print("Error deleting document: $e");
      throw e;
    }
  }

  // Method to fetch all documents from Firestore collection
  Future<List<Map<String, dynamic>>> getProducts(String storeId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(collection)
          .where('stores', isEqualTo: storeId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching documents: $e");
      throw e;
    }
  }

  late final CollectionReference _firestoreReferences =
      FirebaseFirestore.instance.collection(this.collection);

  Future<List<Map<String, dynamic>>> getAllPackages() async {
    List<Map<String, dynamic>> packages = [];
    QuerySnapshot collectionReference = await _firestoreReferences.get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> package = element.data() as Map<String, dynamic>;
      package["id"] = element.id;
      packages.add(package);
    });
    return packages;
  }

  Future<List<Map<String, dynamic>>> getDirectory() async {
    List<Map<String, dynamic>> directory = [];
    QuerySnapshot _collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    _collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> directoryMap =
          element.data() as Map<String, dynamic>;
      directoryMap["id"] = element.id;
      directory.add(directoryMap);
    });
    return directory;
  }

  Future<List<Map<String, dynamic>>> getPoll() async {
    List<Map<String, dynamic>> poll = [];
    QuerySnapshot _collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    _collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> pollMap = element.data() as Map<String, dynamic>;
      pollMap["id"] = element.id;
      poll.add(pollMap);
    });
    return poll;
  }

  Future<List<Map<String, dynamic>>> getDefaulter() async {
    List<Map<String, dynamic>> defaulter = [];
    QuerySnapshot _collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    _collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> defaulterMap =
          element.data() as Map<String, dynamic>;
      defaulterMap["id"] = element.id;
      defaulter.add(defaulterMap);
    });
    return defaulter;
  }

  Future<List<Map<String, dynamic>>> getStores() async {
    List<Map<String, dynamic>> stores = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> storesMap = element.data() as Map<String, dynamic>;
      storesMap["id"] = element.id;
      stores.add(storesMap);
    });
    return stores;
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    List<Map<String, dynamic>> services = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> servicesMap = element.data() as Map<String, dynamic>;
      servicesMap["id"] = element.id;
      services.add(servicesMap);
    });
    return services;
  }

  Future<List<Map<String, dynamic>>> getProductByCategory({
    required String storesId,
    String? categoryId, // Parámetro opcional para filtrar por categoría
  }) async {
    List<Map<String, dynamic>> products = [];

    // Filtrar por tienda y, si se proporciona, también por categoría
    QuerySnapshot collectionReference = await _firestoreReferences
        .where("stores", isEqualTo: storesId)
        .where("category",
            isEqualTo: categoryId) // Filtrar por categoría si existe
        .get();

    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> product = element.data() as Map<String, dynamic>;
      product["id"] = element.id;
      products.add(product);
    });

    return products;
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot collectionReference = await _firestoreReferences.get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> product = element.data() as Map<String, dynamic>;
      product["id"] = element.id;
      products.add(product);
    });
    return products;
  }

  Future<List<Map<String, dynamic>>> getPhotosHome(
      {required String storesId}) async {
    List<Map<String, dynamic>> photos = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.where("storeId", isEqualTo: storesId).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> photo = element.data() as Map<String, dynamic>;
      photo["id"] = element.id;
      photos.add(photo);
    });
    return photos;
  }

  Future<List<Map<String, dynamic>>> getAllPhotos() async {
    List<Map<String, dynamic>> photos = [];
    QuerySnapshot collectionReference = await _firestoreReferences.get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> photo = element.data() as Map<String, dynamic>;
      photo["id"] = element.id;
      photos.add(photo);
    });
    return photos;
  }

  Future<List<Map<String, dynamic>>> getEventCategories() async {
    List<Map<String, dynamic>> eventCategories = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('order', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> eventCategoryMap =
          element.data() as Map<String, dynamic>;
      eventCategoryMap["id"] = element.id;
      eventCategories.add(eventCategoryMap);
    });
    return eventCategories;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    List<Map<String, dynamic>> categories = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('order', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> categoryMap = element.data() as Map<String, dynamic>;
      categoryMap["id"] = element.id;
      categories.add(categoryMap);
    });
    return categories;
  }

  Future<List<Map<String, dynamic>>> getCategoriesHome(
      {required String serviceId}) async {
    List<Map<String, dynamic>> categories = [];
    QuerySnapshot collectionReference = await _firestoreReferences
        .where("serviceId", isEqualTo: serviceId)
        .get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> category = element.data() as Map<String, dynamic>;
      category["id"] = element.id;
      categories.add(category);
    });
    return categories;
  }

  Future<List<Map<String, dynamic>>> getServicesCategories(
      {required String serviceId}) async {
    List<Map<String, dynamic>> categories = [];
    QuerySnapshot collectionReference = await _firestoreReferences
        .where(serviceId, isEqualTo: "services")
        .get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> services = element.data() as Map<String, dynamic>;
      services["id"] = element.id;
      categories.add(services);
    });
    return categories;
  }

  Future<List<Map<String, dynamic>>> getStoresCategories(
      {required String storesId}) async {
    List<Map<String, dynamic>> categories = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.where("stores", isEqualTo: storesId).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> stores = element.data() as Map<String, dynamic>;
      stores["id"] = element.id;
      categories.add(stores);
    });
    return categories;
  }

  Future<Map<String, dynamic>> getBusiness() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId") ?? "";

    Map<String, dynamic> business = {};
    QuerySnapshot collectionReference = await _firestoreReferences
        .where('userId', isEqualTo: business["userId"])
        .get();

    if (collectionReference.docs.isNotEmpty) {
      Map<String, dynamic> businessMap =
          collectionReference.docs[0].data() as Map<String, dynamic>;
      return businessMap;
    }
    print(collectionReference);
    print(collectionReference.docs[0].data);
    return business;
  }

  // esto funciona cuando se trae los negocios de businessLit
  Future<List<Map<String, dynamic>>> getBusinessByService(
      String serviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId") ?? "";

    List<Map<String, dynamic>> filteredBusinessList = [];

    QuerySnapshot collectionReference =
        await _firestoreReferences.where('userId', isEqualTo: userId).get();

    if (collectionReference.docs.isNotEmpty) {
      // Recorre la colección de negocios
      for (var doc in collectionReference.docs) {
        Map<String, dynamic> businessData = doc.data() as Map<String, dynamic>;
        List<dynamic> businessList = businessData["businessList"] ?? [];

        // Filtra los negocios que coincidan con el serviceId
        for (var business in businessList) {
          if (business["businessType"] == serviceId) {
            filteredBusinessList.add(business as Map<String, dynamic>);
          }
        }
      }
    }

    return filteredBusinessList;
  }

  Future<List<Map<String, dynamic>>> getNewBusinessByService(
      String serviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId") ?? "";

    List<Map<String, dynamic>> filteredBusinessList = [];

    // Consulta directamente a la colección `allBusiness`
    QuerySnapshot collectionReference = await FirebaseFirestore.instance
        .collection('allBusiness')
        .where('user', isEqualTo: userId)
        .where('serviceId', isEqualTo: serviceId) // Filtra por tipo de servicio
        .get();

    if (collectionReference.docs.isNotEmpty) {
      // Recorre los documentos de negocios
      for (var doc in collectionReference.docs) {
        Map<String, dynamic> businessData = doc.data() as Map<String, dynamic>;
        businessData["id"] = doc.id; // Añade el ID del documento
        filteredBusinessList
            .add(businessData); // Añade cada negocio filtrado a la lista
      }
    }

    return filteredBusinessList;
  }

  Future<List> getListBusinessForUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("userId") ?? "";
    List businesses = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.where("userId", isEqualTo: userId).get();
    if (collectionReference.docs.isNotEmpty) {
      Map<String, dynamic> business =
          collectionReference.docs[0].data() as Map<String, dynamic>;
      business["id"] = collectionReference.docs[0].id;
      businesses = business["businessList"];
    }
    print(businesses);
    return businesses;
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    List<Map<String, dynamic>> districts = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> district = element.data() as Map<String, dynamic>;
      district["id"] = element.id;
      districts.add(district);
    });
    return districts;
  }

  Future<List<Map<String, dynamic>>> getHotels() async {
    List<Map<String, dynamic>> hotels = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> hotelsMap = element.data() as Map<String, dynamic>;
      hotelsMap["id"] = element.id;
      hotels.add(hotelsMap);
    });
    return hotels;
  }

  Future<List<Map<String, dynamic>>> getHotelRoomsProductHome(
      {required String hotelsId}) async {
    List<Map<String, dynamic>> hotelRooms = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.where("hotels", isEqualTo: hotelsId).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> hotelRoom = element.data() as Map<String, dynamic>;
      hotelRoom["id"] = element.id;
      hotelRooms.add(hotelRoom);
    });
    return hotelRooms;
  }

  Future<List<Map<String, dynamic>>> getCateringServices() async {
    List<Map<String, dynamic>> cateringServices = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> cateringServicesMap =
          element.data() as Map<String, dynamic>;
      cateringServicesMap["id"] = element.id;
      cateringServices.add(cateringServicesMap);
    });
    return cateringServices;
  }

  Future<List<Map<String, dynamic>>> getTortas() async {
    List<Map<String, dynamic>> tortas = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> tortasMap = element.data() as Map<String, dynamic>;
      tortasMap["id"] = element.id;
      tortas.add(tortasMap);
    });
    return tortas;
  }

  Future<List<Map<String, dynamic>>> getCatering() async {
    List<Map<String, dynamic>> catering = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> cateringMap = element.data() as Map<String, dynamic>;
      cateringMap["id"] = element.id;
      catering.add(cateringMap);
    });
    return catering;
  }

  Future<List<Map<String, dynamic>>> getCheffs() async {
    List<Map<String, dynamic>> cheffs = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> cheffsMap = element.data() as Map<String, dynamic>;
      cheffsMap["id"] = element.id;
      cheffs.add(cheffsMap);
    });
    return cheffs;
  }

  Future<List<Map<String, dynamic>>> getHostes() async {
    List<Map<String, dynamic>> hostes = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> hostesMap = element.data() as Map<String, dynamic>;
      hostesMap["id"] = element.id;
      hostes.add(hostesMap);
    });
    return hostes;
  }

  Future<List<Map<String, dynamic>>> getCeremonyMasters() async {
    List<Map<String, dynamic>> ceremonyMasters = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> ceremonyMastersMap =
          element.data() as Map<String, dynamic>;
      ceremonyMastersMap["id"] = element.id;
      ceremonyMasters.add(ceremonyMastersMap);
    });
    return ceremonyMasters;
  }

  Future<List<Map<String, dynamic>>> getParrilleros() async {
    List<Map<String, dynamic>> parrilleros = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> parrillerosMap =
          element.data() as Map<String, dynamic>;
      parrillerosMap["id"] = element.id;
      parrilleros.add(parrillerosMap);
    });
    return parrilleros;
  }

  Future<List<Map<String, dynamic>>> getWaiters() async {
    List<Map<String, dynamic>> waiters = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> waitersMap = element.data() as Map<String, dynamic>;
      waitersMap["id"] = element.id;
      waiters.add(waitersMap);
    });
    return waiters;
  }

  Future<List<Map<String, dynamic>>> getDancers() async {
    List<Map<String, dynamic>> dancers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> dancersMap = element.data() as Map<String, dynamic>;
      dancersMap["id"] = element.id;
      dancers.add(dancersMap);
    });
    return dancers;
  }

  Future<List<Map<String, dynamic>>> getAnimators() async {
    List<Map<String, dynamic>> animators = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> animatorsMap =
          element.data() as Map<String, dynamic>;
      animatorsMap["id"] = element.id;
      animators.add(animatorsMap);
    });
    return animators;
  }

  Future<List<Map<String, dynamic>>> getCrazyHour() async {
    List<Map<String, dynamic>> crazyHour = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> crazyHourMap =
          element.data() as Map<String, dynamic>;
      crazyHourMap["id"] = element.id;
      crazyHour.add(crazyHourMap);
    });
    return crazyHour;
  }

  Future<List<Map<String, dynamic>>> getDjs() async {
    List<Map<String, dynamic>> djs = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> djsMap = element.data() as Map<String, dynamic>;
      djsMap["id"] = element.id;
      djs.add(djsMap);
    });
    return djs;
  }

  Future<List<Map<String, dynamic>>> getSoundMan() async {
    List<Map<String, dynamic>> soundMan = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> soundManMap = element.data() as Map<String, dynamic>;
      soundManMap["id"] = element.id;
      soundMan.add(soundManMap);
    });
    return soundMan;
  }

  Future<List<Map<String, dynamic>>> getBands() async {
    List<Map<String, dynamic>> bands = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> bandsMap = element.data() as Map<String, dynamic>;
      bandsMap["id"] = element.id;
      bands.add(bandsMap);
    });
    return bands;
  }

  Future<List<Map<String, dynamic>>> getLighting() async {
    List<Map<String, dynamic>> lighting = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> lightingMap = element.data() as Map<String, dynamic>;
      lightingMap["id"] = element.id;
      lighting.add(lightingMap);
    });
    return lighting;
  }

  Future<List<Map<String, dynamic>>> getPhotographers() async {
    List<Map<String, dynamic>> photographers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> photographersMap =
          element.data() as Map<String, dynamic>;
      photographersMap["id"] = element.id;
      photographers.add(photographersMap);
    });
    return photographers;
  }

  Future<List<Map<String, dynamic>>> getProduction() async {
    List<Map<String, dynamic>> production = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> productionMap =
          element.data() as Map<String, dynamic>;
      productionMap["id"] = element.id;
      production.add(productionMap);
    });
    return production;
  }

  Future<List<Map<String, dynamic>>> getFilming() async {
    List<Map<String, dynamic>> filming = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> filmingMap = element.data() as Map<String, dynamic>;
      filmingMap["id"] = element.id;
      filming.add(filmingMap);
    });
    return filming;
  }

  Future<List<Map<String, dynamic>>> getValetParking() async {
    List<Map<String, dynamic>> valetParking = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> valetParkingMap =
          element.data() as Map<String, dynamic>;
      valetParkingMap["id"] = element.id;
      valetParking.add(valetParkingMap);
    });
    return valetParking;
  }

  Future<List<Map<String, dynamic>>> getSecurityVip() async {
    List<Map<String, dynamic>> securityVip = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> securityVipMap =
          element.data() as Map<String, dynamic>;
      securityVipMap["id"] = element.id;
      securityVip.add(securityVipMap);
    });
    return securityVip;
  }

  Future<List<Map<String, dynamic>>> getBartenders() async {
    List<Map<String, dynamic>> bartenders = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> bartendersMap =
          element.data() as Map<String, dynamic>;
      bartendersMap["id"] = element.id;
      bartenders.add(bartendersMap);
    });
    return bartenders;
  }

  // Obtener todos los negocios
  Future<List<Map<String, dynamic>>> getAllBusiness() async {
    List<Map<String, dynamic>> bartenders = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> bartendersMap =
          element.data() as Map<String, dynamic>;
      bartendersMap["id"] = element.id;
      bartenders.add(bartendersMap);
    });
    return bartenders;
  }

  Future<List<Map<String, dynamic>>> getAllBusinessByService(
      String serviceId) async {
    List<Map<String, dynamic>> bartenders = [];

    // Filtrar por serviceId antes de obtener los documentos
    QuerySnapshot collectionReference = await _firestoreReferences
        .where('serviceId',
            isEqualTo: serviceId) // Filtrado por tipo de servicio
        //.orderBy('status', descending: true) // Ordenar por status
        .get();

    print("Documentos encontrados: ${collectionReference.docs.length}");

    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> bartendersMap =
          element.data() as Map<String, dynamic>;
      bartendersMap["id"] = element.id; // Añadir el ID del documento
      print("Documento: ${bartendersMap}"); // Imprimir los datos del documento
      bartenders.add(bartendersMap); // Añadir el mapa a la lista de resultados
    });

    return bartenders; // Devolver la lista filtrada
  }

  Future<List<Map<String, dynamic>>> getOrganizers() async {
    List<Map<String, dynamic>> organizers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> organizersMap =
          element.data() as Map<String, dynamic>;
      organizersMap["id"] = element.id;
      organizers.add(organizersMap);
    });
    return organizers;
  }

  Future<List<Map<String, dynamic>>> getInfluencers() async {
    List<Map<String, dynamic>> influencers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> influencersMap =
          element.data() as Map<String, dynamic>;
      influencersMap["id"] = element.id;
      influencers.add(influencersMap);
    });
    return influencers;
  }

  Future<List<Map<String, dynamic>>> getReceptionPlaces() async {
    List<Map<String, dynamic>> receptionPlaces = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> receptionPlacesMap =
          element.data() as Map<String, dynamic>;
      receptionPlacesMap["id"] = element.id;
      receptionPlaces.add(receptionPlacesMap);
    });
    return receptionPlaces;
  }

  Future<List<Map<String, dynamic>>> getInvitations() async {
    List<Map<String, dynamic>> invitations = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> invitationsMap =
          element.data() as Map<String, dynamic>;
      invitationsMap["id"] = element.id;
      invitations.add(invitationsMap);
    });
    return invitations;
  }

  Future<List<Map<String, dynamic>>> getSouvenirs() async {
    List<Map<String, dynamic>> souvenirs = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> souvenirsMap =
          element.data() as Map<String, dynamic>;
      souvenirsMap["id"] = element.id;
      souvenirs.add(souvenirsMap);
    });
    return souvenirs;
  }

  Future<List<Map<String, dynamic>>> getFlowers() async {
    List<Map<String, dynamic>> flowers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> flowersMap = element.data() as Map<String, dynamic>;
      flowersMap["id"] = element.id;
      flowers.add(flowersMap);
    });
    return flowers;
  }

  Future<List<Map<String, dynamic>>> getSuits() async {
    List<Map<String, dynamic>> suits = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> suitsMap = element.data() as Map<String, dynamic>;
      suitsMap["id"] = element.id;
      suits.add(suitsMap);
    });
    return suits;
  }

  Future<List<Map<String, dynamic>>> getBeauty() async {
    List<Map<String, dynamic>> beauty = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> beautyMap = element.data() as Map<String, dynamic>;
      beautyMap["id"] = element.id;
      beauty.add(beautyMap);
    });
    return beauty;
  }

  Future<List<Map<String, dynamic>>> getDresses() async {
    List<Map<String, dynamic>> dresses = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> dressesMap = element.data() as Map<String, dynamic>;
      dressesMap["id"] = element.id;
      dresses.add(dressesMap);
    });
    return dresses;
  }

  Future<List<Map<String, dynamic>>> getMaintenance() async {
    List<Map<String, dynamic>> maintenance = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> maintenanceMap =
          element.data() as Map<String, dynamic>;
      maintenanceMap["id"] = element.id;
      maintenance.add(maintenanceMap);
    });
    return maintenance;
  }

  Future<List<Map<String, dynamic>>> getFurniture() async {
    List<Map<String, dynamic>> furniture = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> furnitureMap =
          element.data() as Map<String, dynamic>;
      furnitureMap["id"] = element.id;
      furniture.add(furnitureMap);
    });
    return furniture;
  }

  Future<List<Map<String, dynamic>>> getTransport() async {
    List<Map<String, dynamic>> transport = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> transportMap =
          element.data() as Map<String, dynamic>;
      transportMap["id"] = element.id;
      transport.add(transportMap);
    });
    return transport;
  }

  Future<List<Map<String, dynamic>>> getJewelers() async {
    List<Map<String, dynamic>> jewelers = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> jewelersMap = element.data() as Map<String, dynamic>;
      jewelersMap["id"] = element.id;
      jewelers.add(jewelersMap);
    });
    return jewelers;
  }

  Future<List<Map<String, dynamic>>> getHoneyMoon() async {
    List<Map<String, dynamic>> honeyMoon = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> honeyMoonMap =
          element.data() as Map<String, dynamic>;
      honeyMoonMap["id"] = element.id;
      honeyMoon.add(honeyMoonMap);
    });
    return honeyMoon;
  }

  // Este es para ver si puedo añadir productos

  Future<List<Map<String, dynamic>>> getEventProducts() async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> productsMap = element.data() as Map<String, dynamic>;
      productsMap["id"] = element.id;
      products.add(productsMap);
    });
    return products;
  }

  Future<List> getComplexInfoForUser() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String userId = _prefs.getString("users") ?? "";
    List complexs = [];
    QuerySnapshot _collectionReference =
        await _firestoreReferences.where("userId", isEqualTo: userId).get();
    if (_collectionReference.docs.isNotEmpty) {
      Map<String, dynamic> complex =
          _collectionReference.docs[0].data() as Map<String, dynamic>;
      complex["id"] = _collectionReference.docs[0].id;
      complexs = complex["complexInfo"];
    }
    print(complexs);
    return complexs;
  }

  Future<List<Map<String, dynamic>>> getAdvertisement() async {
    List<Map<String, dynamic>> advertisement = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> advertisementMap =
          element.data() as Map<String, dynamic>;
      advertisementMap["id"] = element.id;
      advertisement.add(advertisementMap);
    });
    return advertisement;
  }

  Future<List<Map<String, dynamic>>> getAdvertisementList(
      {required String userId}) async {
    List<Map<String, dynamic>> advertisementList = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.where("user", isEqualTo: userId).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> advertisement =
          element.data() as Map<String, dynamic>;
      advertisement["id"] = element.id;
      advertisementList.add(advertisement);
    });
    return advertisementList;
  }

  Future<List<Map<String, dynamic>>> getEventPost() async {
    List<Map<String, dynamic>> eventPost = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('status', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> eventPostMap =
          element.data() as Map<String, dynamic>;
      eventPostMap["id"] = element.id;
      eventPost.add(eventPostMap);
    });
    return eventPost;
  }

  // Obtener los eventos aprobados con entradas, por categoria
  Future<List<Map<String, dynamic>>> getEventPostByCategoryWithTickets(
      {String? category}) async {
    Query collectionReference = _firestoreReferences;

    if (category != null && category.isNotEmpty) {
      // Filtrar por categoría si se proporciona
      collectionReference = collectionReference
          .where('category', isEqualTo: category)
          .where('approved', isEqualTo: true);
    }

    // Obtener los documentos
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Filtrar los documentos en los que el campo 'tickets' no esté vacío
    List<Map<String, dynamic>> filteredDocs = querySnapshot.docs.where((doc) {
      List<dynamic> tickets =
          (doc.data() as Map<String, dynamic>)['tickets'] ?? [];
      return tickets.isNotEmpty; // Solo incluir si 'tickets' no está vacío
    }).map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    // Imprimir el número de documentos filtrados
    print("Número de eventos con tickets no vacíos: ${filteredDocs.length}");

    return filteredDocs;
  }

  // Obtener los eventos con o sin entradas
  Future<List<Map<String, dynamic>>> getEventPostByCategory(
      {String? category}) async {
    Query collectionReference = _firestoreReferences;

    if (category != null && category.isNotEmpty) {
      // Filtrar por categoría si se proporciona
      collectionReference =
          collectionReference.where('category', isEqualTo: category);
    }

    // Eliminar el ordenamiento por 'status'
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Imprimir el número de documentos recuperados
    print("Número de eventos recuperados: ${querySnapshot.docs.length}");

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getFilterTickets(
      String eventPostId) async {
    List<Map<String, dynamic>> tickets = [];
    QuerySnapshot collectionReference = await _collectionReference
        .where('eventPostId', isEqualTo: eventPostId)
        .where('selected', isEqualTo: false)
        .get();

    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> ticketsMap = element.data() as Map<String, dynamic>;
      ticketsMap["id"] = element.id;
      tickets.add(ticketsMap);
    });
    return tickets;
  }

  Future<List<Map<String, dynamic>>> getTickets() async {
    List<Map<String, dynamic>> tickets = [];
    QuerySnapshot collectionReference =
        await _firestoreReferences.orderBy('selected', descending: true).get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> ticketsMap = element.data() as Map<String, dynamic>;
      ticketsMap["id"] = element.id;
      tickets.add(ticketsMap);
    });
    return tickets;
  }

  Future<List<Map<String, dynamic>>> getTicketsByTitle(String title) async {
    List<Map<String, dynamic>> tickets = [];
    QuerySnapshot collectionReference = await _firestoreReferences
        .where('title', isEqualTo: title) // Filtra por el título específico
        .orderBy('selected', descending: true)
        .get();

    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> ticketsMap = element.data() as Map<String, dynamic>;
      ticketsMap["id"] = element.id;
      tickets.add(ticketsMap);
    });
    return tickets;
  }

  // Obtener anuncios aprobados
  Stream<QuerySnapshot> getApprovedAdvertisementsStream() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('approved', isEqualTo: true) // Solo anuncios aprobados
        .snapshots(); // Esto devuelve un Stream para escuchar cambios en tiempo real
  }

  // Obtener anuncios pendientes de aprobación (esto puede seguir siendo un Future)
  Future<QuerySnapshot> getPendingAdvertisements() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('approved', isEqualTo: false) // Anuncios no aprobados
        .get();
  }

  // Aprobar un anuncio
  Future<void> approveAdvertisement(String adId) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(adId)
        .update({'approved': true}); // Actualizar el estado a 'true'
  }

  // Función para rechazar el anuncio
  Future<void> rejectAdvertisement(String adId, String rejectionReason) {
    return FirebaseFirestore.instance.collection(collection).doc(adId).update({
      'approved': false, // No aprobado
      'rejected': true, // Marcar como rechazado
      'rejectionReason': rejectionReason, // Guardar la razón del rechazo
    });
  }

  // Obtener anuncios rechazados
  Future<QuerySnapshot> getRejectedAdvertisements() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('rejected', isEqualTo: true) // Filtrar por anuncios rechazados
        .get();
  }

  // Obtener posts activados
  Stream<QuerySnapshot> getActivatedPostsStream() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('active', isEqualTo: true) // Solo posts aprobados
        .snapshots(); // Esto devuelve un Stream para escuchar cambios en tiempo real
  }

  // Obtener posts desactivados
  Future<QuerySnapshot> getDisactivatedPosts() {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('active', isEqualTo: false) // Filtrar por anuncios rechazados
        .get();
  }

  // Obtener anuncios pendientes del usuario
  Stream<QuerySnapshot> getPendingAdvertisementsByUser(String userId) {
    return _db
        .collection(collection)
        .where('user', isEqualTo: userId)
        .where('approved', isEqualTo: false)
        .where('rejected', isEqualTo: false)
        .snapshots();
  }

  // Obtener anuncios aprobados del usuario
  Stream<QuerySnapshot> getApprovedAdvertisementsByUser(String userId) {
    return _db
        .collection(collection)
        .where('user', isEqualTo: userId)
        .where('approved', isEqualTo: true)
        .snapshots();
  }

  // Obtener anuncios rechazados del usuario
  Stream<QuerySnapshot> getRejectedAdvertisementsByUser(String userId) {
    return _db
        .collection(collection)
        .where('user', isEqualTo: userId)
        .where('rejected', isEqualTo: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getUserTickets(String userId) async {
    QuerySnapshot querySnapshot = await _firestoreReferences
        .where('userId', isEqualTo: userId)
        .where('selected', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    QuerySnapshot querySnapshot =
        await _firestoreReferences.where('userId', isEqualTo: userId).get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getEventPostByUser(String userId) async {
    List<Map<String, dynamic>> eventPost = [];
    QuerySnapshot collectionReference = await _firestoreReferences
        .where('user', isEqualTo: userId) // Filtra por el ID de usuario
        //.orderBy('status', descending: true)
        .get();
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> eventPostMap =
          element.data() as Map<String, dynamic>;
      eventPostMap["id"] = element.id;
      eventPost.add(eventPostMap);
    });
    return eventPost;
  }

  Future<List<Map<String, dynamic>>> getEventPostWithTicketsByUser(
      String userId) async {
    List<Map<String, dynamic>> eventPost = [];

    // Obtener los documentos de Firestore filtrando por el userId
    QuerySnapshot collectionReference = await _firestoreReferences
        .where('user', isEqualTo: userId) // Filtra por el ID de usuario
        .where('rejected', isEqualTo: false)
        .get();

    // Filtrar los documentos que tienen el campo 'tickets' no vacío
    collectionReference.docs.forEach((QueryDocumentSnapshot element) {
      Map<String, dynamic> eventPostMap =
          element.data() as Map<String, dynamic>;

      // Verificar si el campo 'tickets' existe y no está vacío
      if (eventPostMap['tickets'] != null &&
          (eventPostMap['tickets'] as List).isNotEmpty) {
        eventPostMap["id"] = element.id; // Añadir el id del documento
        eventPost.add(eventPostMap); // Añadir el mapa a la lista
      }
    });

    return eventPost;
  }

  Future<List<Map<String, dynamic>>> getEventTickets(String eventId) async {
    QuerySnapshot querySnapshot = await _firestoreReferences
        .where('eventPostId', isEqualTo: eventId)
        .get();

    // Crear un mapa para agrupar los tickets por título
    Map<String, Map<String, dynamic>> ticketGroups = {};

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String title = data['title'];

      if (ticketGroups.containsKey(title)) {
        // Si el título ya existe, actualizar los conteos
        ticketGroups[title]!['totalCreated'] += 1;
        if (data['selected'] == true) {
          ticketGroups[title]!['totalSold'] += 1;
        }
      } else {
        // Si el título no existe, crear una nueva entrada
        ticketGroups[title] = {
          'title': title,
          'totalCreated': 1,
          'totalSold': data['selected'] == true ? 1 : 0,
        };
      }
    });

    // Convertir el mapa a una lista
    return ticketGroups.values.toList();
  }

  Future<List<DocumentSnapshot>> fetchDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? complexId = prefs.getString('complexId');
    if (complexId == null) {
      throw Exception("No se encontró el complexId en SharedPreferences");
    }

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("complexs")
        .doc(complexId)
        .collection("directory")
        .get();

    print("Documentos obtenidos: ${querySnapshot.docs.length}");
    for (var doc in querySnapshot.docs) {
      print("Documento: ${doc.data()}");
    }

    return querySnapshot.docs;
  }

  Future<String?> getComplexIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('complexId');
  }

  Future<List<DocumentSnapshot>> newFetchDirectory({int? workerType}) async {
    String? complexId = await getComplexIdFromPreferences();
    print("El complexId no está disponible en SharedPreferences.");
    if (complexId == null) return [];

    CollectionReference directoryRef = FirebaseFirestore.instance
        .collection('complexs')
        .doc(complexId)
        .collection('directory');

    Query query = directoryRef;
    if (workerType != null) {
      query = query.where('workerType', isEqualTo: workerType);
    }

    QuerySnapshot snapshot = await query.get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchDocuments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? complexId = prefs.getString('complexId');
    if (complexId == null) {
      throw Exception("No se encontró el complexId en SharedPreferences");
    }

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("complexs")
        .doc(complexId)
        .collection("documents")
        .get();

    print("Documentos obtenidos: ${querySnapshot.docs.length}");
    for (var doc in querySnapshot.docs) {
      print("Documento: ${doc.data()}");
    }

    return querySnapshot.docs;
  }

/*
  addFirestore(Map<String, dynamic> data) {
    _firestoreReferences.add(data).then((value) {
      print("Datos registrados");
    });
  }

  updateProduct(Map<String, dynamic> product) {}

  deleteProduct(String productId) {}*/
}
