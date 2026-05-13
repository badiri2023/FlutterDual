import 'package:flutter/material.dart';
import '../servicios/api_servicio.dart';

class DialogoRegistro extends StatefulWidget {
  const DialogoRegistro({super.key});

  @override
  State<DialogoRegistro> createState() => _DialogoRegistroState();
}

class _DialogoRegistroState extends State<DialogoRegistro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _registrarUsuario() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _cargando = true;
    });

    final resultado = await ApiServicio.registrarUsuario(
      _nombreController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }

    if (resultado['exito'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Cuenta y mazo inicial creados con éxito!")), 
        );
        Navigator.pop(context, _emailController.text);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensaje']), 
            backgroundColor: Colors.red, 
          ), 
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Crear Nueva Cuenta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              
              TextFormField(
                controller: _nombreController, 
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Dinos cómo te llamas';
                  if (value.length < 3) return 'Nombre demasiado corto';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) return 'Email no válido';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _passwordController, 
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 157, 101, 10),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _cargando ? null : _registrarUsuario,
                  
                  child: _cargando 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('REGISTRARSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}