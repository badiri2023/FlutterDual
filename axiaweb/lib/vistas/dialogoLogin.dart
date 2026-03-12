import 'package:flutter/material.dart';

class DialogoLogin extends StatefulWidget {
  const DialogoLogin({super.key});

  @override
  State<DialogoLogin> createState() => _DialogoLoginState();
}

class _DialogoLoginState extends State<DialogoLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Función para mostrar el diálogo de "Recuperar Contraseña"
  void _mostrarRecuperarPassword() {
    // Cerramos el login antes de abrir el de recuperación
    Navigator.pop(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Recuperar Contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              'Introduce tu email y te enviaremos un enlace para que vuelvas a entrar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Tu correo electrónico', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí irá: await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo de recuperación enviado. Revisa tu bandeja de entrada.')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('ENVIAR ENLACE'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Iniciar Sesión', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
              validator: (value) => (value == null || !value.contains('@')) ? 'Email no válido' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
              validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            
            // --- AQUÍ ESTÁ EL BOTÓN QUE BUSCABAS ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _mostrarRecuperarPassword,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('ENTRAR'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}