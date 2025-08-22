// CREATE A BLUE PRINT TO MAKE USECASES ACROSS THE APP

abstract class Usecase<Type,Params>{
  Future<Type> call ({Params params});
}