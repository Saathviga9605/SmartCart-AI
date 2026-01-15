// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroceryCategoryAdapter extends TypeAdapter<GroceryCategory> {
  @override
  final int typeId = 1;

  @override
  GroceryCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GroceryCategory.fruits;
      case 1:
        return GroceryCategory.vegetables;
      case 2:
        return GroceryCategory.dairy;
      case 3:
        return GroceryCategory.meat;
      case 4:
        return GroceryCategory.bakery;
      case 5:
        return GroceryCategory.beverages;
      case 6:
        return GroceryCategory.snacks;
      case 7:
        return GroceryCategory.other;
      default:
        return GroceryCategory.fruits;
    }
  }

  @override
  void write(BinaryWriter writer, GroceryCategory obj) {
    switch (obj) {
      case GroceryCategory.fruits:
        writer.writeByte(0);
        break;
      case GroceryCategory.vegetables:
        writer.writeByte(1);
        break;
      case GroceryCategory.dairy:
        writer.writeByte(2);
        break;
      case GroceryCategory.meat:
        writer.writeByte(3);
        break;
      case GroceryCategory.bakery:
        writer.writeByte(4);
        break;
      case GroceryCategory.beverages:
        writer.writeByte(5);
        break;
      case GroceryCategory.snacks:
        writer.writeByte(6);
        break;
      case GroceryCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
