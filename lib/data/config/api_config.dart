class ApiConfig {
  static const String searchBaseUrl = 'http://localhost:8085';
  static const String graphqlUrl = '$searchBaseUrl/search';
  
  static const String productServiceUrl = 'http://localhost:8082';
  
  static const String brandsEndpoint = '$productServiceUrl/product-service/brands/'; 
  
  static const String mediaBaseUrl = 'http://localhost:8084/media/';
}