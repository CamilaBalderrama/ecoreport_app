import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    // Validación básica de campos vacíos
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu usuario y contraseña.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Si todo está correcto, navega a la pantalla principal borrando el historial de rutas
    Navigator.pushReplacementNamed(context, '/report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo corporativo centrado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
                ),
                child: Image.asset(
                  'assets/logo.png',
                  height: 72,
                  width: 72,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.eco, size: 72, color: Color(0xFF2E7D32));
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Título de bienvenida
              const Text(
                'EcoReport GPS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sistema de monitoreo y reporte ambiental',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Tarjeta contenedora del formulario
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Campo de Usuario
                      TextField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          hintText: 'Ingresa tu usuario',
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF2E7D32)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de Contraseña
                      TextField(
                        controller: _passController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de Ingresar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleLogin,
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}