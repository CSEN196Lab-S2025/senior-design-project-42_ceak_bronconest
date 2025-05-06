import 'package:flutter/material.dart';

class FilterHousesPage extends StatefulWidget {
  const FilterHousesPage({super.key});

  @override
  State<FilterHousesPage> createState() => _FilterHousesPageState();
}

class _FilterHousesPageState extends State<FilterHousesPage> {
  double _minPrice = 0;
  double _maxPrice = 5000;
  double _maxDistance = 10;
  double _minBedrooms = 1;
  double _minBathrooms = 1;
  bool isLoading = false;

  Future<void> _submitFilter() async {
    setState(() {
      isLoading = true;
    });

    try {
      final filters = {
        'minPrice': _minPrice,
        'maxPrice': _maxPrice,
        'maxDistance': _maxDistance,
        'minBedrooms': _minBedrooms,
        'minBathrooms': _minBathrooms,
      };

      Navigator.of(context).pop(filters);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Filter applied')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error applying filter: $e')));
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
      appBar: AppBar(title: const Text('Filter Houses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:
              isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Applying filters...',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter your house search using the options below:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text('Price Range (\$):'),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 5000,
                        divisions: 100,
                        inactiveColor: Colors.black26,
                        labels: RangeLabels(
                          '\$${_minPrice.toInt()}',
                          '\$${_maxPrice.toInt()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Max Distance from Campus (miles):'),
                      Slider(
                        value: _maxDistance,
                        min: 0,
                        max: 10,
                        divisions: 100,
                        inactiveColor: Colors.black26,
                        label: '${_maxDistance.toInt()} miles',
                        onChanged: (value) {
                          setState(() {
                            _maxDistance = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Minimum Bedrooms:'),
                      Slider(
                        value: _minBedrooms,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        inactiveColor: Colors.black26,
                        label: '${_minBedrooms.toInt()}',
                        onChanged: (value) {
                          setState(() {
                            _minBedrooms = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Minimum Bathrooms:'),
                      Slider(
                        value: _minBathrooms,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        inactiveColor: Colors.black26,
                        label: '${_minBathrooms.toInt()}',
                        onChanged: (value) {
                          setState(() {
                            _minBathrooms = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitFilter,
                        child: const Text('Apply Filter'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
