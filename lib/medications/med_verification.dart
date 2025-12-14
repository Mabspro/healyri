import 'package:flutter/material.dart';

class MedVerification extends StatefulWidget {
  const MedVerification({Key? key}) : super(key: key);

  @override
  State<MedVerification> createState() => _MedVerificationState();
}

class _MedVerificationState extends State<MedVerification> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  bool _isScanning = false;
  VerificationResult? _verificationResult;

  @override
  void dispose() {
    _barcodeController.dispose();
    _medicationNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildScanSection(),
            const SizedBox(height: 24),
            _buildManualEntrySection(),
            const SizedBox(height: 24),
            if (_verificationResult != null) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medication Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify your medications to ensure they are genuine and safe to use. You can scan the barcode or enter the details manually.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This service is powered by SafeMeds Zambia and helps combat counterfeit medications.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan Medication Barcode',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: _isScanning
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Scanning...'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isScanning = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text('Tap to scan barcode'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isScanning = true;
                          });
                          // Simulate scanning
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                _isScanning = false;
                                _barcodeController.text = '5901234123457';
                                _verifyMedication();
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Start Scanning'),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _barcodeController,
          decoration: InputDecoration(
            labelText: 'Barcode Number',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _verifyMedication();
              },
            ),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildManualEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or Enter Details Manually',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _medicationNameController,
          decoration: const InputDecoration(
            labelText: 'Medication Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _manufacturerController,
          decoration: const InputDecoration(
            labelText: 'Manufacturer',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _batchNumberController,
          decoration: const InputDecoration(
            labelText: 'Batch Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _expiryDateController,
          decoration: const InputDecoration(
            labelText: 'Expiry Date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _verifyMedicationManually();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Verify Medication'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    final result = _verificationResult!;
    final isGenuine = result.isGenuine;

    return Card(
      color: isGenuine ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isGenuine ? Icons.check_circle : Icons.error,
                  color: isGenuine ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isGenuine ? 'Genuine Medication' : 'Potential Counterfeit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isGenuine ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultRow('Medication', result.medicationName),
            _buildResultRow('Manufacturer', result.manufacturer),
            _buildResultRow('Batch Number', result.batchNumber),
            _buildResultRow('Expiry Date', result.expiryDate),
            _buildResultRow('Verification Date', result.verificationDate),
            const SizedBox(height: 16),
            Text(
              result.message,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isGenuine ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            if (!isGenuine)
              ElevatedButton.icon(
                onPressed: () {
                  _showReportDialog();
                },
                icon: const Icon(Icons.report),
                label: const Text('Report Counterfeit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _verifyMedication() {
    // Simulate API call to verify medication
    if (_barcodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a barcode number'),
        ),
      );
      return;
    }

    // For demo purposes, we'll simulate a verification result
    setState(() {
      _verificationResult = VerificationResult(
        isGenuine: true,
        medicationName: 'Paracetamol 500mg',
        manufacturer: 'Zambia Pharmaceuticals Ltd',
        batchNumber: 'ZPL2023-456',
        expiryDate: '12/2025',
        verificationDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        message: 'This medication has been verified as genuine and is safe to use.',
      );
    });

    // Scroll to the result section
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _verifyMedicationManually() {
    // Validate inputs
    if (_medicationNameController.text.isEmpty ||
        _manufacturerController.text.isEmpty ||
        _batchNumberController.text.isEmpty ||
        _expiryDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    // For demo purposes, we'll simulate a verification result
    // In a real app, this would call an API to verify the medication
    final isFake = _batchNumberController.text.contains('FAKE');

    setState(() {
      _verificationResult = VerificationResult(
        isGenuine: !isFake,
        medicationName: _medicationNameController.text,
        manufacturer: _manufacturerController.text,
        batchNumber: _batchNumberController.text,
        expiryDate: _expiryDateController.text,
        verificationDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        message: isFake
            ? 'WARNING: This medication could not be verified as genuine. Please consult a healthcare professional before use.'
            : 'This medication has been verified as genuine and is safe to use.',
      );
    });

    // Scroll to the result section
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Counterfeit Medication'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thank you for helping to combat counterfeit medications. Please provide additional information about where you obtained this medication:',
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Purchase Location',
                  border: OutlineInputBorder(),
                  hintText: 'Name of pharmacy or store',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Additional Details',
                  border: OutlineInputBorder(),
                  hintText: 'Any other information that might be helpful',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted successfully. Thank you for helping to keep medications safe.'),
                    duration: Duration(seconds: 5),
                  ),
                );
              },
              child: const Text('Submit Report'),
            ),
          ],
        );
      },
    );
  }
}

class VerificationResult {
  final bool isGenuine;
  final String medicationName;
  final String manufacturer;
  final String batchNumber;
  final String expiryDate;
  final String verificationDate;
  final String message;

  VerificationResult({
    required this.isGenuine,
    required this.medicationName,
    required this.manufacturer,
    required this.batchNumber,
    required this.expiryDate,
    required this.verificationDate,
    required this.message,
  });
}
