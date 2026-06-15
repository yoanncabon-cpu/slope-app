import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slope/app.dart';

void main() {
  testWidgets('Slope app launches and shows home after loading', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SlopeApp());

    // Pendant le chargement des données, le splash screen est affiché.
    expect(find.text('Slope'), findsWidgets);

    // Le chargement des assets et de SharedPreferences passe par de vraies
    // opérations asynchrones : on laisse le vrai event loop tourner via
    // runAsync, puis on rafraîchit l'arbre de widgets.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Une fois chargé, la navigation principale est visible.
    expect(find.text('Bienvenue sur Slope'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
