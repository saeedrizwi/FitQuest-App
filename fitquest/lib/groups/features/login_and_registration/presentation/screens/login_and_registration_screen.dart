import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/my_scaffold.dart';
import '../widgets/separator.dart';
import 'content/login_content.dart';
import 'content/register_content.dart';


class LoginAndRegistrationScreen extends StatefulWidget {
  static const String route = '/login';

  const LoginAndRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LoginAndRegistrationScreen> createState() => _LoginAndRegistrationScreenState();
}

class _LoginAndRegistrationScreenState extends State<LoginAndRegistrationScreen> {
  final ValueNotifier<String?> notifyError = ValueNotifier<String?>(null);
  late LoginAndRegistrationContent content;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    final List<dynamic> goToLoginHelper = [];
    loginContent({String? email}) => LoginContent(email: email, notifyError: notifyError, goToLogin: (message, email) => (goToLoginHelper[0] as GoToLoginCallback)(message, email));
    goToLoginHelper.add(
        (message, email) => setState(() {
          content = loginContent(email: email,);
          successMessage = message;
        })
    );
    content = loginContent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        appBar: null,
        background:  Container(
          color: Colors.blue[600], // Solid blue background
        ),
        body: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Top spacing if needed
                SizedBox(height: MediaQuery.of(context).size.height * .1,),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Simple and bold welcome text
                    const Text(
                      'Welcome to FitQuest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Circular container with a soft gradient background and subtle shadow for the icon
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: const Icon(
                        Icons.fitness_center_sharp,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),


                content,

                // error message
                ValueListenableBuilder(
                    valueListenable: notifyError,
                    builder: (context, error, widget) => error == null || error.isEmpty
                        ? Container()
                        : Column(
                      children: [
                        separator,
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Text(error, style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                            )
                        )
                      ],
                    )
                ),

                const SizedBox(height: 15,),
                Align(
                  alignment: const Alignment(.93,0),
                  child: InkWell(
                    child: Ink(
                      child: Text(content.nextContent.title, style: const TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.w800)),
                    ),
                    onTap: () {
                      setState(() {
                        notifyError.value = null;
                        content = content.nextContent;
                      });
                    },
                  ),
                ),

                if(successMessage?.isNotEmpty == true)
                  ...[
                    const SizedBox(height: 20,),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: Text(successMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.green[900], fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                        )
                    )
                  ],

                const SizedBox(height: 50,)
              ],
            ),
          ),
        )
    );
  }
}

abstract class LoginAndRegistrationContent extends Widget {
  const LoginAndRegistrationContent({super.key});

  String get title;
  LoginAndRegistrationContent get nextContent;
}

