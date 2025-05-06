import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/styles.dart';

class AddDormPage extends StatefulWidget {
  const AddDormPage({super.key});

  @override
  State<AddDormPage> createState() => _AddDormPageState();
}

class _AddDormPageState extends State<AddDormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _coverImage;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'cover_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
      return '';
    }
  }

  Future<void> _submitDorm() async {
    if (_nameController.text.isEmpty ||
        _shortDescriptionController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _latController.text.isEmpty ||
        _longController.text.isEmpty ||
        _coverImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (double.tryParse(_latController.text) == null ||
        double.tryParse(_longController.text) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid coordinates')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final imageUrl = await _uploadImage(_coverImage!);
      if (imageUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error uploading image')),
          );
        }
        return;
      }

      final docRef =
          FirebaseFirestore.instance
              .collection('schools')
              .doc(school)
              .collection('dorms')
              .doc();

      final dorm = Dorm(
        id: docRef.id,
        name: _nameController.text,
        shortDescription: _shortDescriptionController.text,
        locationAddress: _addressController.text,
        coverImage: imageUrl,
        locationLongLat: (
          double.parse(_longController.text),
          double.parse(_latController.text),
        ),
        reviews: [],
        walkabilityAvg: 0.0,
        cleanlinessAvg: 0.0,
        quietnessAvg: 0.0,
        comfortAvg: 0.0,
        safetyAvg: 0.0,
        amenitiesAvg: 0.0,
        communityAvg: 0.0,
      );

      await docRef.set(dorm.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dorm added successfully')),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding dorm: $e')));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Dorm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            // spacing: 5.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Info', style: Styles.mediumTextStyle),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _shortDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Text('Location', style: Styles.mediumTextStyle),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _longController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Media', style: Styles.mediumTextStyle),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _coverImage == null
                          ? const Center(child: Text('Pick a cover image'))
                          : Image.file(_coverImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitDorm,
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Add Dorm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
