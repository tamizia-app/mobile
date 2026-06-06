import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamizia_app/app.dart';

void main() {
  testWidgets('navega por las pantallas iniciales de autenticacion', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(const TamiziaApp());

    expect(find.text('LectorRisk'), findsOneWidget);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('TamizIA'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNWidgets(2));

    await tester.tap(find.text('Crear cuenta docente'));
    await tester.pumpAndSettle();
    expect(find.text('Crear cuenta docente'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    expect(find.text('Recuperar contraseña'), findsOneWidget);
  });

  testWidgets('valida campos obligatorios en login', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(const TamiziaApp());
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pump();

    expect(find.text('El correo electrónico es obligatorio.'), findsOneWidget);
  });

  testWidgets('login exitoso navega al dashboard docente', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 860));
    await tester.pumpWidget(const TamiziaApp());
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'ejemplo@escuela.edu'),
      'docente@escuela.edu',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Juan'), findsOneWidget);
    expect(find.text('Accesos rápidos'), findsOneWidget);
  });
}
