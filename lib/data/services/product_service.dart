import 'dart:math';
import '../models/brand.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _generateMockProducts(20);
  }

  List<Product> _generateMockProducts(int count) {
    final random = Random();
    final now = DateTime.now();

    final sampleNames = ['Футболка "Оверсайз"', 'Джинсы "Слим"', 'Худи "Классик"', 'Кроссовки "Урбан"', 'Рубашка "Лён"'];
    final sampleBrands = ['Nike', 'Adidas', 'Puma', 'Reebok', 'Zara'];
    final sampleCategories = ['Верхняя одежда', 'Нижняя одежда', 'Обувь', 'Аксессуары'];
    final sampleColors = ['Черный', 'Белый', 'Синий', 'Красный', 'Зеленый', 'Серый'];
    final sampleSizes = ['S', 'M', 'L', 'XL'];
    final sampleMaterials = ['Хлопок', 'Полиэстер', 'Лён', 'Шерсть', 'Кожа'];

    return List.generate(count, (productIndex) {
      final brandName = sampleBrands[random.nextInt(sampleBrands.length)];
      final categoryName = sampleCategories[random.nextInt(sampleCategories.length)];
      final basePrice = (random.nextInt(4500) + 500).toDouble();
      
      final variantCount = random.nextInt(4) + 1;
      List<String> usedColors = [];

      final List<ProductVariant> variants = List.generate(variantCount, (variantIndex) {
        String color;
        do {
          color = sampleColors[random.nextInt(sampleColors.length)];
        } while (usedColors.contains(color));
        usedColors.add(color);

        return ProductVariant(
          id: (productIndex + 1) * 100 + variantIndex,
          sku: 'SKU-${productIndex + 1}-$variantIndex',
          price: basePrice + (variantIndex * 50),
          material: sampleMaterials[random.nextInt(sampleMaterials.length)],
          createdAt: now.subtract(Duration(days: random.nextInt(30))),
          updatedAt: now.subtract(Duration(hours: random.nextInt(72))),
          deletedAt: null,
          rating: (random.nextDouble() * 2.0 + 3.0).clamp(3.0, 5.0),
          reviewCount: random.nextInt(200),
          reservedStock: random.nextInt(10),
          stock: random.nextInt(100),
          imageURLs: ['https://picsum.photos/seed/${productIndex * 10 + variantIndex + 1}/400/600'],
          barcode: (random.nextInt(90000000) + 10000000).toString(),
          dimensions: '${random.nextInt(50)+10}x${random.nextInt(40)+10}x${random.nextInt(10)+2} см',
          discount: (productIndex % 3 == 0) ? (random.nextInt(40) + 10).toDouble() : 0.0,
          isActive: random.nextBool(),
          minOrder: 1,
          sizes: sampleSizes[random.nextInt(sampleSizes.length)],
          colors: color,
        );
      });

      return Product(
        id: productIndex + 1,
        name: '${sampleNames[random.nextInt(sampleNames.length)]} $brandName',
        description: 'Это подробное описание для продукта...',
        imageURLs: variants.first.imageURLs,
        brand: Brand(
          id: productIndex + 50,
          name: brandName,
          description: 'Описание бренда $brandName',
          logo: 'https://logo.com/seed/$brandName/logo.png',
          videoUrl: 'https://videos.com/seed/$brandName/promo.mp4',
        ),
        category: Category(
          id: productIndex + 150,
          name: categoryName,
          description: 'Описание категории $categoryName',
          imageUrl: 'https://picsum.photos/seed/cat${productIndex+1}/200',
        ),
        variants: variants,
        isActive: true,
        videoURLs: [],
        createdAt: now.subtract(Duration(days: random.nextInt(60), hours: 5)),
        updatedAt: now.subtract(Duration(minutes: random.nextInt(300))),
        deletedAt: null,
      );
    });
  }
}