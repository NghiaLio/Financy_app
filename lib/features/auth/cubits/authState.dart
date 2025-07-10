abstract class Authstate {}

class initialAuth extends Authstate{}

class loadingAuth extends Authstate{}

class Auth extends Authstate{
  bool isGoogle;
  Auth(this.isGoogle); 
}

class ErrorAuth extends Authstate{}