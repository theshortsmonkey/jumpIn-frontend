import 'package:flutter/material.dart';

class ContainerWithBackgroundImage extends StatelessWidget {
  final Widget child;

  const ContainerWithBackgroundImage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("web/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

class ContainerWithBackgroundColor extends StatelessWidget {
  final Widget child;

  const ContainerWithBackgroundColor({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: child,
    );
  }
}
