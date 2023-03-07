import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:gap/gap.dart';
import 'package:tripo/repo/repository.dart';

Widget notFound(BuildContext context) {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.shade200,
        ),
        child: const Icon(
          IconlyBroken.search,
          color: Colors.grey,
          size: 100,
        ),
      ),
      const Gap(20),
      Text(
        'No Transaction Found',
        style: TextStyle(color: Repository.textColor(context)),
      )
    ],
  ));
}
