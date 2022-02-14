# **Xapptor Business**
[![pub package](https://img.shields.io/pub/v/xapptor_business?color=blue)](https://pub.dartlang.org/packages/xapptor_business)
### Module for business analytics and payment processing.

## **Let's get started**

### **1 - Depend on it**
##### Add it to your package's pubspec.yaml file
```yml
dependencies:
    xapptor_business: ^0.0.3
```

### **2 - Install it**
##### Install packages from the command line
```sh
flutter pub get
```

### **3 - Learn it like a charm**

#### **Admin Analytics**
```dart
AdminAnalytics(
    text_color: Colors.black,
    icon_color: Colors.blue,
);
```

#### **Dispenser Details**
```dart
DispenserDetails(
    product: product,
    dispenser: dispenser,
    dispenser_id: dispenser_id,
    allow_edit: true,
    update_enabled_in_dispenser: update_enabled_in_dispenser_function,
);
```

#### **Payment Webview**
```dart
PaymentWebview(
    url_base: url,
);
```

#### **Product Catalog**
```dart
ProductCatalog(
    topbar_color: Colors.blue,
    language_picker_items_text_color: Colors.cyan,
    products: products,
    linear_gradients: linear_gradients,
    texts: text_list_product_catalog,
    background_color: Colors.blue,
    title_color: Colors.white,
    subtitle_color: Colors.white,
    text_color: Colors.white,
    button_color: Colors.cyan,
    success_url: "https://www.yourdomain.com/home?payment_success=true",
    cancel_url: "https://www.yourdomain.com/home?payment_success=false",
);
```

#### **Product Details**
```dart
ProductDetails(
    product: product,
    is_editing: true,
    text_color: Colors.black,
    title_color: Colors.blue,
);
```

#### **Product List**
```dart
ProductList(
    vending_machine_id: vending_machine_id,
    allow_edit: false,
    has_topbar: false,
    for_dispensers: true,
    text_color: Colors.blue,
    topbar_color: Colors.cyan,
    title_color: Color.green,
);
```

#### **Vending Machine Details**
```dart
VendingMachineDetails(
    vending_machine: vending_machine,
    text_color: Colors.black,
    topbar_color: Colors.blue,
    textfield_color: Colors.black,
);
```

### **4 - Check Abeinstitute Repo for more examples**
[Abeinstitute Repo](https://github.com/Xapptor/abeinstitute)

[Abeinstitute](https://www.abeinstitute.com)