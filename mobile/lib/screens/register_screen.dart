import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _formation = 'Licence Informatique';
  String _niveau = 'L3';
  String _promotion = '2025';
  bool _accepted = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Créer un compte'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rejoignez le réseau social interne officiel de l’UADB',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _labeledField(
                          'Prénom',
                          TextField(
                            controller: _firstName,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Aminata',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _labeledField(
                          'Nom',
                          TextField(
                            controller: _lastName,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Diallo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _labeledField(
                    'Email universitaire (@uadb.edu.sn)',
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'votre.nom@uadb.edu.sn',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _labeledField(
                          'Mot de passe',
                          TextField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _labeledField(
                          'Confirmer',
                          TextField(
                            controller: _confirm,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _labeledField(
                          'Formation',
                          DropdownButtonFormField<String>(
                            initialValue: _formation,
                            items: const [
                              DropdownMenuItem(
                                value: 'Licence Informatique',
                                child: Text('Licence Informatique'),
                              ),
                              DropdownMenuItem(
                                value: 'Licence Mathématiques',
                                child: Text('Licence Mathématiques'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _formation = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _labeledField(
                          'Niveau',
                          DropdownButtonFormField<String>(
                            initialValue: _niveau,
                            items: const [
                              DropdownMenuItem(value: 'L1', child: Text('L1')),
                              DropdownMenuItem(value: 'L2', child: Text('L2')),
                              DropdownMenuItem(value: 'L3', child: Text('L3')),
                              DropdownMenuItem(value: 'M1', child: Text('M1')),
                              DropdownMenuItem(value: 'M2', child: Text('M2')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _niveau = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _labeledField(
                          'Promotion',
                          DropdownButtonFormField<String>(
                            initialValue: _promotion,
                            items: const [
                              DropdownMenuItem(
                                value: '2024',
                                child: Text('2024'),
                              ),
                              DropdownMenuItem(
                                value: '2025',
                                child: Text('2025'),
                              ),
                              DropdownMenuItem(
                                value: '2026',
                                child: Text('2026'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _promotion = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _accepted,
                    onChanged: (value) =>
                        setState(() => _accepted = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'J’accepte les conditions d’utilisation et la politique de confidentialité de l’UADB',
                      style: TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _accepted ? () {} : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        disabledBackgroundColor: AppColors.green.withValues(
                          alpha: 0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Créer mon compte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
