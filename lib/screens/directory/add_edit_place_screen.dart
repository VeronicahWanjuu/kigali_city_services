import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/place_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/loading_overlay.dart';
// image_picker import removed — no Storage means no image upload

class AddEditPlaceScreen extends StatefulWidget {
  final PlaceModel? place;
  const AddEditPlaceScreen({this.place, super.key});
  @override
  State<AddEditPlaceScreen> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _latCtrl     = TextEditingController();
  final _lngCtrl     = TextEditingController();
  String _selectedCategory = 'Hospital';
  bool _loading = false;


  bool get _isEditMode => widget.place != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.place!;
      _nameCtrl.text    = p.name;
      _addressCtrl.text = p.address;
      _contactCtrl.text = p.contactNumber;
      _descCtrl.text    = p.description;
      _latCtrl.text     = p.latitude.toString();
      _lngCtrl.text     = p.longitude.toString();
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _contactCtrl.dispose();
    _descCtrl.dispose(); _latCtrl.dispose(); _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name    = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final desc    = _descCtrl.text.trim();
    final latStr  = _latCtrl.text.trim();
    final lngStr  = _lngCtrl.text.trim();

    if (name.isEmpty || address.isEmpty || contact.isEmpty ||
        desc.isEmpty || latStr.isEmpty || lngStr.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill in all fields.');
      return;
    }
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    if (lat == null || lng == null) {
      CustomSnackbar.showError(context, 'Coordinates must be valid numbers.');
      return;
    }
    if (lat < -3.0 || lat > -1.0 || lng < 29.0 || lng > 31.5) {
      CustomSnackbar.showError(context, 'Coordinates seem outside Rwanda. Please check.');
      return;
    }

    setState(() => _loading = true);
    final auth     = context.read<AppAuthProvider>();
    final provider = context.read<PlaceProvider>();

    final place = PlaceModel(
      id: _isEditMode ? widget.place!.id : '',
      name: name, category: _selectedCategory,
      address: address, contactNumber: contact,
      description: desc, latitude: lat, longitude: lng,
      createdBy: auth.currentUser?.uid ?? '',
      creatorName: auth.currentUser?.displayName ?? '',
      createdAt: _isEditMode ? widget.place!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: null, 
    );

   
    final success = _isEditMode
        ? await provider.updatePlace(place)
        : await provider.createPlace(place);

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess(context, _isEditMode ? 'Place updated!' : 'Place added!');
    } else { CustomSnackbar.showError(context, provider.errorMessage ?? 'Something went wrong.'); }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Place' : 'Add Place'),
          actions: [
            TextButton(
              onPressed: _loading ? null : _save,
              child: const Text('Save',
                style: TextStyle(color: kAccentGold, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            
            Container(
              width: double.infinity, height: 80,
              decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(12)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.image_not_supported, color: kTextSecondary, size: 24),
                SizedBox(width: 8),
                Text('Image upload not available on free plan',
                  style: kCaptionText),
              ]),
            ),

            const SizedBox(height: 16),
            // Category dropdown
            const Text('Category', style: kCaptionText),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: kCardDark,
              style: kBodyText,
              decoration: const InputDecoration(),
              items: kCategories.skip(1).map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 12),
            _field(_nameCtrl, 'Place Name'),
            _field(_addressCtrl, 'Address'),
            _field(_contactCtrl, 'Contact Number', type: TextInputType.phone),
            _field(_descCtrl, 'Description', maxLines: 3),
            const Text('GPS Coordinates', style: kHeadingMedium),
            const SizedBox(height: 4),
            const Text('Go to Google Maps → find place → long-press to see coordinates',
              style: kCaptionText),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _field(_latCtrl, 'Latitude  e.g. -1.9441',
                type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
              const SizedBox(width: 12),
              Expanded(child: _field(_lngCtrl, 'Longitude  e.g. 30.0619',
                type: const TextInputType.numberWithOptions(decimal: true, signed: true))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType? type, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        style: kBodyText,
      ),
    );
  }
}
