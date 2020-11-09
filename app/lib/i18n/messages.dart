import 'package:get/route_manager.dart';

class Messages extends Translations {
  Map<String, Map<String, String>> get keys => {
        'fr': {
          'app.title': 'Les graisseux',
          'onboarding.profile.choice_customer':
              "J'ai besoin d'un coup de main sur ma voiture",
          'onboarding.profile.choice_mechanic':
              "Je propose mon aide / mes outils"
        },
        'en': {
          'app.title': 'Greasers',
          'onboarding.title.register': 'Register',
          'onboarding.title.job': 'New job',
          'onboarding.title.mechanic': 'My mechanic profile',
          'onboarding.job_services.title': 'What service do you need ?',
          'onboarding.job_services.add': 'Select a service',
          'onboarding.profile.choice_customer': "I need a hand with my car",
          'onboarding.profile.choice_mechanic':
              "I'm up for help / lending my tools"
        }
      };
}
