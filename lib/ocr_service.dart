import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'bill_split_screen.dart';

Future<String> extractTextFromReceipt(XFile imageFile) async {
  final inputImage = InputImage.fromFilePath(imageFile.path);
  final textRecognizer = GoogleMlKit.vision.textRecognizer();
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
  
  return recognizedText.text; // Return the extracted text
}

List<Item> parseReceiptText(String text) {
  List<Item> items = [];
  List<String> lines = text.split("\n");

  for (String line in lines) {
    // Regular expression to detect prices
    final priceRegExp = RegExp(r'\$([0-9]+(?:\.[0-9]{1,2})?)');
    final match = priceRegExp.firstMatch(line);

    if (match != null) {
      // Extract price and item name (everything before the price)
      double price = double.tryParse(match.group(0)!.replaceAll('\$', '')) ?? 0.0;
      String name = line.substring(0, match.start).trim(); // Everything before the price is the item name

      items.add(Item(name: name, price: price, assignedPerson: ''));
    }
  }

  return items;
}