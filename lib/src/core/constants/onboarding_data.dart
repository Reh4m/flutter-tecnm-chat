import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/data/models/onboarding_model.dart';

class OnboardingData {
  static const List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Conéctate con tu comunidad',
      description:
          'Comunícate fácilmente con alumnos y profesores del TecNM Celaya desde una sola app segura y moderna.',
      iconData: 'forum',
    ),
    OnboardingModel(
      title: 'Privacidad garantizada',
      description:
          'Tu número de teléfono permanece oculto. Tú decides qué información compartir con tus contactos.',
      iconData: 'privacy',
    ),
    OnboardingModel(
      title: 'Chats y grupos escolares',
      description:
          'Organiza conversaciones individuales y grupales, participa en debates y mantente al día con tu clase.',
      iconData: 'community',
    ),
    OnboardingModel(
      title: 'Comunicación avanzada',
      description:
          'Envía fotos, videos y emojis, o realiza videollamadas de manera sencilla desde tu dispositivo.',
      iconData: 'call',
    ),
  ];

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'forum':
        return Icons.forum;
      case 'privacy':
        return Icons.privacy_tip;
      case 'community':
        return Icons.group;
      case 'call':
        return Icons.video_call;
      default:
        return Icons.info;
    }
  }
}
