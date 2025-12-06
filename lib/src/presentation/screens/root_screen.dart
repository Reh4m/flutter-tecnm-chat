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

  final List<Widget> _screens = [
    const ConversationsListScreen(),
    const ContactsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeListeners();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  void _initializeListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();

      if (userProvider.currentUser != null) {
        _startAllListeners(userProvider.currentUser!.id);
      } else {
        userProvider.addListener(_onUserLoaded);
      }
    });
  }

  void _startAllListeners(String userId) {
    context.read<DirectChatProvider>().startChatsListener(userId);
    context.read<ContactsProvider>().startContactsListener(userId);
    context.read<GroupChatProvider>().startGroupsListener(userId);
  }

  void _onUserLoaded() {
    final userProvider = context.read<UserProvider>();

    if (userProvider.currentUser != null) {
      userProvider.removeListener(_onUserLoaded);
      _startAllListeners(userProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = context.read<UserProvider>();
        final directChatProvider = context.read<DirectChatProvider>();
        final contactsProvider = context.read<ContactsProvider>();
        final groupChatProvider = context.read<GroupChatProvider>();

        directChatProvider.stopChatsListener();
        contactsProvider.stopContactsListener();
        groupChatProvider.stopGroupsListener();
        userProvider.removeListener(_onUserLoaded);
        userProvider.clearCurrentUser();
      }
    });
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
