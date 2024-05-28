
import 'package:flutter/material.dart';
import './api.dart';
import "./auth_provider.dart";
import 'package:provider/provider.dart';

class UploadImageForm extends StatefulWidget {
  const UploadImageForm({super.key});

  @override
  State<UploadImageForm> createState() => _UploadImageForm();
}

class _UploadImageForm extends State<UploadImageForm> {
  final _imageUrlController = TextEditingController();
  String _imageUrl = '';
  bool _isWebImage = false;
  
  void _handleUploadPic() async {  
    try {
    final currUser = context.read<AuthState>().userInfo;
      await uploadUserProfilePic(currUser.username,_imageUrlController.text);
      await Future.delayed(const Duration(seconds: 1), () async {
        imageCache.clear();
        imageCache.clearLiveImages();
        Navigator.of(context).pushNamed('/profile');
    });
    } catch (e) {
      print(e);
    }
  }
  ImageProvider? _setImage () {
    ImageProvider? profilePic;
    _isWebImage 
                  ? _imageUrl != '' ? profilePic = NetworkImage(_imageUrl): null
                  : _imageUrl != '' ? profilePic = AssetImage(_imageUrl): null;
    return profilePic;
  }
  @override
  Widget build(BuildContext context) {
    return 
    Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Upload a new profile picture', style: Theme.of(context).textTheme.headlineMedium),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'image url/filepath'),
              onChanged: (value) {
              setState(() {
                _imageUrlController.text.startsWith('http') 
                ? _isWebImage = true 
                : _isWebImage = false;
                _imageUrl = _imageUrlController.text;
              });
              },
            ),
          ),
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 70,
                backgroundImage: _setImage()
              ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.blue;
              }),
            ),
            onPressed: _handleUploadPic,
            child: const Text('Upload image'),
          ),
        ],
      ),
    );
  }
}
