//登录时异常
class InvalidLoginCredentialsException implements Exception{}

//注册时异常
class WeakPasswordAuthException implements Exception{}

class EmailAlreadyInUseAuthException implements Exception{}

class InvalidEmailAuthException implements Exception{}


//通用异常
class GenericAuthException implements Exception{}
//没有用户登录但是却调用了退出登录或验证邮箱方法
class UserNotLoggedInAuthException implements Exception{}
