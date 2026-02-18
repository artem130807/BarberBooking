import 'package:barber_booking_app/providers/authProviders/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/authProviders/email_verify_provider.dart';

class VerifyCodeUpdatePassScreen extends StatefulWidget {
  const VerifyCodeUpdatePassScreen({super.key});

  @override
  State<VerifyCodeUpdatePassScreen> createState() => _VerifyCodeUpdatePassScreenState();
}

class _VerifyCodeUpdatePassScreenState extends State<VerifyCodeUpdatePassScreen> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getFullCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  void _clearCode() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailVerifyProvider>(
      builder: (context, emailProvider, child) {
        final verifiedEmail = emailProvider.verifiedEmail ?? 'example@gmail.com';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (emailProvider.errorMessage != null && mounted) {
            emailProvider.showApiError(context, emailProvider.errorMessage);
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: emailProvider.isLoading
                  ? null
                  : () => Navigator.pushReplacementNamed(context, '/forgot'),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Icon(
                      Icons.mark_chat_read_outlined,
                      size: 80,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Подтверждение кода',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Введите 6-значный код, отправленный на\n$verifiedEmail',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Код подтверждения',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 55,
                        child: TextField(
                          controller: _codeControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          enabled: !emailProvider.isLoading,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: emailProvider.isLoading
                          ? null
                          : () async {
                              String code = _getFullCode();
                              if (code.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Введите полный код'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              bool result = await emailProvider.verificationCode(code);
                              if (result && mounted) {
                                Provider.of<AuthProvider>(context, listen: false)
                                   .setVerifiedEmail(emailProvider.verifiedEmail!);
                                Navigator.pushReplacementNamed(context, '/update-password');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: emailProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Подтвердить',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Не пришел код?'),
                      TextButton(
                        onPressed: emailProvider.isLoading
                            ? null
                            : () {
                                if (emailProvider.verifiedEmail != null) {
                                  emailProvider.sendVerificationCode(
                                    emailProvider.verifiedEmail!,
                                  );
                                  _clearCode();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Сначала введите email'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                        child: const Text(
                          'Отправить повторно',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}