import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/presentation/widgets/apploader.dart';
import 'package:todo_app/core/constants/colors.dart';
import 'package:todo_app/core/constants/style.dart';
import '../../../domain/entity/todo_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/todo/todo_bloc.dart';
import '../../widgets/app_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<TodoBloc>().add(const LoadTodosEvent());
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TodoBloc>().add(const LoadMoreTodosEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Do List',
          style: AppTextStyles.textStyle_700_14_inter.copyWith(
            color:  colors.onPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor:colors.primary,
        elevation: 2,
        actions: [
          IconButton(onPressed: () {
            Navigator.pushNamed(context, '/settings');
          }, icon: Icon(Icons.settings,   color: colors.onPrimary,)),
        
        ],
        leading: BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      final imagePath = state.user.profilePicturePath;

      return IconButton(
        onPressed: () {
          debugPrint("Profile tapped");
          Navigator.pushNamed(context, '/profile');
        },
        icon: CircleAvatar(
          radius: 22,
          backgroundColor: colors.onPrimary,
          backgroundImage: imagePath != null &&
                  File(imagePath).existsSync()
              ? FileImage(File(imagePath))
              : const AssetImage('assets/images/applogo.png')
                  as ImageProvider,
        ),
      );
    }

    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, '/profile');
      },
      icon: const CircleAvatar(
        radius: 22,
        child: Icon(Icons.person),
      ),
    );
  },
),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: 
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search todos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TodoBloc>().add(
                            const SearchTodosEvent(''),
                          );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                context.read<TodoBloc>().add(SearchTodosEvent(value));
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError && !state.hasCachedData) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoLoading) {
            return const AppLoader();
          }

          if (state is TodoEmpty) {
            return _buildEmptyState(state.isSearching);
          }

          if (state is TodoError) {
            if (state.hasCachedData) {
              return _buildTodoList(
                state.cachedTodos,
                hasReachedMax: true,
                isOffline: true,
              );
            }
            return _buildErrorState(state.message);
          }

          if (state is TodoLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TodoBloc>().add(const RefreshTodosEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: Column(
                children: [
                  if (state.isOffline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: Colors.orange.shade100,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Offline - Showing cached data',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _buildTodoList(
                      state.todos,
                      hasReachedMax: state.hasReachedMax,
                      isOffline: state.isOffline,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is TodoLoadingMore) {
            return Column(
              children: [
                Expanded(
                  child: _buildTodoList(
                    state.currentTodos,
                    hasReachedMax: false,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTodoList(
    List<Todo> todos, {
    required bool hasReachedMax,
    bool isOffline = false,
  }) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: hasReachedMax ? todos.length : todos.length + 1,
      itemBuilder: (context, index) {
        if (index >= todos.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final todo = todos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildTodoCard(Todo todo) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) {
            context.read<TodoBloc>().add(ToggleCompletedEvent(todo));
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
  todo.title,
  style: TextStyle(
    decoration:
        todo.completed ? TextDecoration.lineThrough : null,
    color: todo.completed
        ? colors.onSurface.withOpacity(0.5)
        : colors.onSurface,
    fontSize: 16,
  ),
),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'User ID: ${todo.userId}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            todo.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: todo.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            context.read<TodoBloc>().add(ToggleFavoriteEvent(todo));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inbox,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No todos found' : 'No todos available',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 8),
            const Text(
              'Try a different search term',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TodoBloc>().add(const LoadTodosEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
