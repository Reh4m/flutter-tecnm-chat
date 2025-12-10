import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/contacts/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/conversations/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/screens/profile/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/widgets/app/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late final UserProvider _userProvider;
  late final DirectChatProvider _directChatProvider;
  late final ContactsProvider _contactsProvider;
  late final GroupChatProvider _groupChatProvider;

  VoidCallback? _userListenerCallback;
  String? _currentUserId;
  bool _listenersInitialized = false;

  final List<Widget> _screens = [
    const ConversationsListScreen(),
    const ContactsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _userProvider = context.read<UserProvider>();
    _directChatProvider = context.read<DirectChatProvider>();
    _contactsProvider = context.read<ContactsProvider>();
    _groupChatProvider = context.read<GroupChatProvider>();

    // Agregar listener para cambios de usuario
    _userListenerCallback = _onUserChanged;
    _userProvider.addListener(_userListenerCallback!);

    // Verificar usuario inicial
    _onUserChanged();
  }

  void _onUserChanged() {
    final currentUser = _userProvider.currentUser;
    final newUserId = currentUser?.id;

    // Solo actualizar si el usuario cambió
    if (newUserId == _currentUserId) return;

    // Detener listeners anteriores si había un usuario
    if (_currentUserId != null && _listenersInitialized) {
      _stopAllListeners();
    }

    // Actualizar el ID del usuario actual
    _currentUserId = newUserId;

    // Iniciar nuevos listeners si hay usuario
    if (currentUser != null) {
      _startAllListeners(currentUser.id);
    }
  }

  void _startAllListeners(String userId) {
    _directChatProvider.startChatsListener(userId);
    _contactsProvider.startContactsListener(userId);
    _groupChatProvider.startGroupsListener(userId);
    _listenersInitialized = true;
  }

  void _stopAllListeners() {
    _directChatProvider.stopChatsListener();
    _contactsProvider.stopContactsListener();
    _groupChatProvider.stopGroupsListener();
    _listenersInitialized = false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    // Remover el listener del UserProvider
    if (_userListenerCallback != null) {
      _userProvider.removeListener(_userListenerCallback!);
    }

    // Detener todos los listeners inmediatamente
    if (_listenersInitialized) {
      _stopAllListeners();
    }

    // Dispose del controller
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabSelected: _onItemTapped,
      ),
    );
  }
}
