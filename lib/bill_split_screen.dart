import 'package:flutter/material.dart';
import 'ocr_service.dart'; // Assuming you have an OCR service to extract text from images

class Item {
  String name;
  double price;
  String assignedPerson;

  // Constructor remains unchanged, but it's public now
  Item({
    required this.name,
    required this.price,
    required this.assignedPerson,
  });
}

class BillSplitScreen extends StatefulWidget {
  final List<String> groupNames;
  final String extractedText;

  // Simplified constructor using super parameter for 'key'
  const BillSplitScreen({
    super.key, // Converted 'key' to a super parameter
    required this.groupNames,
    required this.extractedText,
  });

  @override
  BillSplitScreenState createState() => BillSplitScreenState(); // Made the state class public
}

class BillSplitScreenState extends State<BillSplitScreen> { // Made the class public
  List<Item> items = [];
  double taxAmount = 0.0;
  double tipAmount = 0.0;
  double totalAmount = 0.0;

  bool isTaxPercentage = true;
  bool isTipPercentage = true;
  bool isTaxAmount = false;

  @override
  void initState() {
    super.initState();
    // Parse the extracted text into items and prices (simple parsing example)
    items = parseReceiptText(widget.extractedText);
  }

   void _calculateTotal() {
    Map<String, double> totalPerPerson = {};
    for (String name in widget.groupNames) {
      totalPerPerson[name] = 0.0;
    }

    // Calculate totals for each person based on assigned items
    for (Item item in items) {
      if (item.assignedPerson.isNotEmpty) {
        totalPerPerson[item.assignedPerson] = (totalPerPerson[item.assignedPerson] ?? 0.0) + item.price;
      }
    }

    // Add tax and tip evenly
    double totalTaxAndTip = taxAmount + tipAmount;
    double taxAndTipPerPerson = totalTaxAndTip / widget.groupNames.length;
    totalPerPerson.updateAll((key, value) => value + taxAndTipPerPerson);

    // Show the total amount owed by each person
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Total Per Person"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: totalPerPerson.entries.map((entry) {
              return Text("${entry.key} owes: \$${entry.value.toStringAsFixed(2)}");
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Split the Bill")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tax and Tip Inputs
            TextField(
              decoration: InputDecoration(labelText: "Tax Amount"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  taxAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "Tip Amount"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  tipAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16),
            // Items List with dropdowns
            if (items.isNotEmpty)
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: item.assignedPerson.isEmpty ? Colors.red[50] : Colors.green[50],
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text("Price: \$${item.price.toStringAsFixed(2)}"),
                        trailing: DropdownButton<String>(
                          hint: Text("Assign"),
                          value: item.assignedPerson.isEmpty ? null : item.assignedPerson,
                          onChanged: (String? newPerson) {
                            setState(() {
                              item.assignedPerson = newPerson ?? '';
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: '',
                              child: Text('Unassigned'),
                            ),
                            ...widget.groupNames.map((name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Text("No items found in receipt."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateTotal,
              child: Text("Calculate Total"),
            ),
          ],
        ),
      ),
    );
  }
}
