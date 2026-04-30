import 'package:go_router/go_router.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../utils/locator.dart';
import '../../data/services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final authService = locator<AuthService>();
    final isLoggedIn = await authService.isLoggedIn();
    
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToWelcome = state.matchedLocation == '/';
    
    // If NOT logged in and trying to access a protected route (e.g., /main)
    if (!isLoggedIn && !isGoingToLogin && !isGoingToWelcome) {
      return '/login';
    }

    // If logged in and trying to access initial screens, redirect to main
    if (isLoggedIn && (isGoingToLogin || isGoingToWelcome)) {
      return '/main';
    }
    
    // Otherwise stay on the current route
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);
