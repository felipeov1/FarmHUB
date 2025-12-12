import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/mainNavigation.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  var messageError = '';
  bool isLoading = false;
  bool isLogin = true;

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      messageError = '';
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void submitAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        messageError = "Preencha todos os campos!";
      });
      return;
    }

    if (!isLogin && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        messageError = "As senhas não conferem!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      messageError = '';
    });

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw SocketException("No internet");
      }

      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      setState(() => isLoading = false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation()),
        );
      }
    } on SocketException catch (_) {
      setState(() {
        isLoading = false;
        messageError =
        "Sem conexão com a internet. Verifique sua conexão e tente novamente.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;

        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {

          messageError = "Email ou senha incorretos.";
        } else if (e.code == 'wrong-password') {
          messageError = "Senha incorreta.";
        } else if (e.code == 'email-already-in-use') {
          messageError = "Este email já está cadastrado.";
        } else if (e.code == 'weak-password') {
          messageError = "A senha é muito fraca.";
        } else if (e.code == 'invalid-email') {
          messageError = "Email inválido.";
        } else {
          messageError = "Erro inesperado, por favor entrar em contato com o suporte"
              "";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print("Erro Inesperado Detalhado: $e");
        messageError = "Erro inesperado. Tente novamente.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/login.webp'),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                colorFilter: ColorFilter.mode(
                  const Color.fromRGBO(0, 0, 0, 0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isLogin ? 'Bem-vindo ao' : 'Crie sua conta no',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                          ),
                          children: const [
                            TextSpan(
                                text: "Farm",
                                style: TextStyle(color: Colors.green)),
                            TextSpan(
                                text: "HUB",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (messageError.isNotEmpty)
                      Container(
                        width: 300,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.redAccent,
                        ),
                        child: Text(
                          messageError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    if (!isLogin) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Senha',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: isLoading ? null : submitAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        isLogin ? 'Entrar' : 'Cadastrar',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: toggleAuthMode,
                      child: Text(
                        isLogin
                            ? 'Não tem uma conta? Cadastre-se'
                            : 'Já tem uma conta? Entre',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}