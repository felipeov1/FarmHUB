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
  var messageError = '';
  bool isLoading = false;

  void auntentication() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        messageError = "Preencha o email e a senha!";
      });
      return;
    } else if (_emailController.text.isEmpty) {
      setState(() {
        messageError = "Preencha o email!";
      });
      return;
    } else if (_passwordController.text.isEmpty) {
      setState(() {
        messageError = "Preencha a senha!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      messageError = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;

        if (e.code == 'user-not-found') {
          messageError = "Usuário não encontrado";
        } else if (e.code == 'wrong-password') {
          messageError = "Senha incorreta";
        } else if (e.code == 'invalid-email') {
          messageError = "Email inválido";
        } else {
          messageError =
              "Erro de autenticação, verifique os dados e tente novamente.";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        messageError = "Erro inesperado, reinicie o app ou contate o suporte.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                const Text(
                  'Bem-vindo ao',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
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
                        height: 1,
                      ),
                      children: const [
                        TextSpan(
                          text: "Farm",
                          style: TextStyle(color: Colors.green),
                        ),
                        TextSpan(
                          text: "HUB",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                if (messageError.isNotEmpty)
                  Center(
                    child: Container(
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
                  decoration: InputDecoration(
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

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: isLoading ? null : auntentication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(color: Colors.black),
                        ),
                ),

                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
