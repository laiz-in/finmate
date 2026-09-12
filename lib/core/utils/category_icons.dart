import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Maps a spending category name to a representative Iconsax icon.
/// Falls back to a generic wallet icon for custom/unknown categories.
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food & Drink':
      return Icons.font_download_sharp;
    case 'Groceries':
      return Iconsax.shopping_cart;
    case 'Transport':
      return Iconsax.car;
    case 'Shopping':
      return Iconsax.bag_2;
    case 'Bills & Utilities':
      return Iconsax.receipt_2;
    case 'Rent & Housing':
      return Iconsax.house_2;
    case 'Entertainment':
      return Iconsax.video_play;
    case 'Health':
      return Iconsax.heart;
    case 'Travel':
      return Iconsax.airplane;
    case 'Education':
      return Iconsax.book_1;
    case 'Other':
      return Iconsax.wallet_1;
    default:
      return Iconsax.wallet_1;
  }
}