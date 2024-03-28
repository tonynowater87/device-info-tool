import 'package:device_info_tool/view/androiddistribution/android_distribution_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AndroidDistributionPage extends StatefulWidget {
  const AndroidDistributionPage({super.key});

  @override
  State<AndroidDistributionPage> createState() => _AndroidDistributionPageState();
}

class _AndroidDistributionPageState extends State<AndroidDistributionPage> {


  @override
  void initState() {
    super.initState();
    context.read<AndroidDistributionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
