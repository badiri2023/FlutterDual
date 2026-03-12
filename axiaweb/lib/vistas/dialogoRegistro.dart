import 'package:flutter/material.dart';

class DialogoRegistro extends StatefulWidget {
  const DialogoRegistro({super.key});

  @override
  State<DialogoRegistro> createState() => _DialogoRegistroState();
}

class _DialogoRegistroState extends State<DialogoRegistro> {
  // La llave mágica para las validaciones
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        // Esto hace que el formulario suba cuando aparece el teclado
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView( // Por si el formulario es largo en móviles pequeños
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador visual de que se puede deslizar
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
              
              // CAMPO: Nombre de Usuario
              TextFormField(
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

              // CAMPO: Email
              TextFormField(
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

              // CAMPO: Contraseña
              TextFormField(
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

              // BOTÓN: Registrarse (Estilo ancho y llamativo)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 157, 101, 10),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Si todo está correcto, disparamos el registro
                    if (_formKey.currentState!.validate()) {
                      // Simulación de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Creando cuenta en MoonShine Studio...')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('REGISTRARSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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