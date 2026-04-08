import 'package:flutter/material.dart';
import '../servicios/api_servicio.dart';

class DialogoLogin extends StatefulWidget {
  const DialogoLogin({super.key});

  @override
  State<DialogoLogin> createState() => _DialogoLoginState();
}

class _DialogoLoginState extends State<DialogoLogin> {
  final _formKey = GlobalKey<FormState>();
  
  // Fíjate que eliminamos el controlador de recuperación de aquí.
  // Ahora este widget solo se preocupa de sus propias cosas (el Login).
  final TextEditingController _emailLoginController = TextEditingController();
  final TextEditingController _passwordLoginController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      final resultado = await ApiServicio.hacerLogin(
        _emailLoginController.text,
        _passwordLoginController.text,
      );

      if (mounted) setState(() => _cargando = false);

      if (resultado['exito'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Bienvenido de vuelta!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resultado['mensaje']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _mostrarRecuperarPassword() {
    // Cerramos el Dialogo de Login (esto destruye sus controladores)
    Navigator.pop(context);
    
    // Abrimos el nuevo Dialogo (que ahora es un widget independiente con su propio controlador)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const DialogoRecuperarPassword(), // Llamamos al nuevo widget aquí
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
              controller: _emailLoginController,
              decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
              validator: (value) => (value == null || !value.contains('@')) ? 'Email no válido' : null,
            ),
            const SizedBox(height: 15),
            
            TextFormField(
              controller: _passwordLoginController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
              validator: (value) => (value == null || value.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            
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
                onPressed: _cargando ? null : _iniciarSesion,
                child: _cargando
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ENTRAR'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// --- NUEVO WIDGET INDEPENDIENTE ---
// Al ser un StatefulWidget aparte, tiene su propio ciclo de vida y no choca con el Login.
class DialogoRecuperarPassword extends StatefulWidget {
  const DialogoRecuperarPassword({super.key});

  @override
  State<DialogoRecuperarPassword> createState() => _DialogoRecuperarPasswordState();
}

class _DialogoRecuperarPasswordState extends State<DialogoRecuperarPassword> {
  // Ahora este controlador vive seguro aquí adentro
  final TextEditingController _emailRecuperacionController = TextEditingController();

  @override
  void dispose() {
    _emailRecuperacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            controller: _emailRecuperacionController,
            decoration: const InputDecoration(labelText: 'Tu correo electrónico', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Correo de recuperación enviado. Revisa tu bandeja de entrada.')),
                );
                Navigator.pop(context); // Cierra este modal
              },
              child: const Text('ENVIAR ENLACE'),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}