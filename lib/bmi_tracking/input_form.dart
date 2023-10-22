import 'package:flutter/material.dart';

class BMIRecordForm extends StatelessWidget {
  const BMIRecordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BMIRecordInputFormInternalScaffold();
  }
}

class _BMIRecordInputFormInternalScaffold extends StatelessWidget {
  const _BMIRecordInputFormInternalScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BMI Form")),
      body: Container(),
    );
  }
}

class _BMIRecordInputFormInternal extends StatelessWidget {
  const _BMIRecordInputFormInternal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
