import 'package:fe/classes/user_class.dart';
import 'package:flutter/material.dart';


class UserCard extends StatelessWidget {
  final User user;
  const UserCard({
    super.key,
    required this.user
  });

  @override
  Widget build(BuildContext context) {    
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(user.username),
              ]
            ),
          ]
           
        ),
      ),
    );
  }
}