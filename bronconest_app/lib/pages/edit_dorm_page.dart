import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/globals.dart';

class EditDormPage extends StatefulWidget {
  final Dorm dorm;

  const EditDormPage({super.key, required this.dorm});

  @override
  State<EditDormPage> createState() => _EditDormPageState();
}

class _EditDormPageState extends State<EditDormPage> {
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
  void initState() {
    super.initState();
    _nameController.text = widget.dorm.name;
    _shortDescriptionController.text = widget.dorm.shortDescription;
    _addressController.text = widget.dorm.locationAddress;
    _latController.text = widget.dorm.locationLongLat.$2.toString();
    _longController.text = widget.dorm.locationLongLat.$1.toString();
  }

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

      final docRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('dorms')
          .doc(widget.dorm.id);

      final dorm = Dorm(
        id: widget.dorm.id,
        name: _nameController.text,
        shortDescription: _shortDescriptionController.text,
        locationAddress: _addressController.text,
        coverImage: imageUrl,
        locationLongLat: (
          double.parse(_longController.text),
          double.parse(_latController.text),
        ),
        reviews: widget.dorm.reviews,
        walkabilityAvg: widget.dorm.walkabilityAvg,
        cleanlinessAvg: widget.dorm.cleanlinessAvg,
        quietnessAvg: widget.dorm.quietnessAvg,
        comfortAvg: widget.dorm.comfortAvg,
        safetyAvg: widget.dorm.safetyAvg,
        amenitiesAvg: widget.dorm.amenitiesAvg,
        communityAvg: widget.dorm.communityAvg,
      );

      await docRef.update(dorm.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dorm edited successfully')),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error editing dorm: $e')));
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
      appBar: AppBar(title: Text('Edit ${widget.dorm.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _shortDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16),
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
                          ? CachedNetworkImage(
                            imageUrl: widget.dorm.coverImage,
                            placeholder:
                                (context, url) =>
                                    const CircularProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                            fit: BoxFit.cover,
                          )
                          : Image.file(_coverImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _longController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _submitDorm,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Edit Dorm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
