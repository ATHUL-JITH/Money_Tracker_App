import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import '../app_pages/input.dart';
import '../database_management/shared_preferences_services.dart';
import '../localization/methods.dart';
import '../provider.dart';
import 'alert_dialog.dart';
import 'category_item.dart';
import 'constants.dart';
import 'custom_toast.dart';

class SaveButton extends StatefulWidget {
  final bool saveInput;
  final Function? saveCategoryFunc;
  final bool? saveFunction;
  const SaveButton(this.saveInput, this.saveCategoryFunc, this.saveFunction);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          if (widget.saveInput) {
            saveInputFunc(context, widget.saveFunction!);
          } else {
            widget.saveCategoryFunc!();
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: white, backgroundColor: Color.fromRGBO(236, 158, 66, 1), padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w), disabledForegroundColor: grey.withOpacity(0.38), disabledBackgroundColor: grey.withOpacity(0.12),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0.r),
          ),
        ),
        label: Text(
          getTranslated(context, 'Save')!,
          style: TextStyle(fontSize: 25.sp),
        ),
        icon: Icon(
          Icons.save,
          size: 25.sp,
        ),
      ),
    );
  }
}

class SaveAndDeleteButton extends StatelessWidget {
  final bool saveAndDeleteInput;
  final Function? saveCategory;
  final String? parentExpenseItem, categoryName;
  final BuildContext? contextEx, contextExEdit, contextIn, contextInEdit;
  final GlobalKey<FormState>? formKey;
  const SaveAndDeleteButton({
    required this.saveAndDeleteInput,
    this.saveCategory,
    this.categoryName,
    this.parentExpenseItem,
    this.contextEx,
    this.contextExEdit,
    this.contextIn,
    this.contextInEdit,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
            onPressed: () {
              if (this.saveAndDeleteInput) {
                deleteInputFunction(
                  context,
                );
              } else {
                deleteCategoryFunction(
                  context: context,
                  categoryName: this.categoryName!,
                  parentExpenseItem: this.parentExpenseItem,
                  contextEx: this.contextEx,
                  contextExEdit: this.contextExEdit,
                  contextIn: this.contextIn,
                  contextInEdit: this.contextInEdit,
                );
              }
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: red, backgroundColor: white, padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w), disabledForegroundColor: grey.withOpacity(0.38), disabledBackgroundColor: grey.withOpacity(0.12),
                side: BorderSide(
                  color: red,
                  width: 2.h,
                ),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0.r),
                )),
            icon: Icon(
              Icons.delete,
              size: 25.sp,
            ),
            label: Text(
              getTranslated(context, 'Delete')!,
              style: TextStyle(fontSize: 25.sp),
            )),
        SaveButton(saveAndDeleteInput, this.saveCategory, false),
      ],
    );
  }
}

Future<void> deleteCategoryFunction(
    {required BuildContext context,
    required String categoryName,
    String? parentExpenseItem,
    BuildContext? contextEx,
    contextExEdit,
    contextIn,
    contextInEdit}) async {
  void onDeletion() {
    if (contextInEdit != null) {
      List<CategoryItem> incomeItems = sharedPrefs.getItems('income items');
      incomeItems.removeWhere((item) => item.text == categoryName);
      sharedPrefs.saveItems('income items', incomeItems);
      Provider.of<ChangeIncomeItemEdit>(contextInEdit, listen: false)
          .getIncomeItems();
      if (contextIn != null) {
        Provider.of<ChangeIncomeItem>(contextIn, listen: false)
            .getIncomeItems();
      }
    } else {
      if (parentExpenseItem == null) {
        sharedPrefs.removeItem(categoryName);
        var parentExpenseItemNames = sharedPrefs.parentExpenseItemNames;
        parentExpenseItemNames.removeWhere(
            (parentExpenseItemName) => categoryName == parentExpenseItemName);
        sharedPrefs.parentExpenseItemNames = parentExpenseItemNames;
      } else {
        List<CategoryItem> expenseItems =
            sharedPrefs.getItems(parentExpenseItem);
        expenseItems.removeWhere((item) => item.text == categoryName);
        sharedPrefs.saveItems(parentExpenseItem, expenseItems);
      }
      Provider.of<ChangeExpenseItem>(contextEx!, listen: false)
          .getAllExpenseItems();
      Provider.of<ChangeExpenseItemEdit>(contextExEdit!, listen: false)
          .getAllExpenseItems();
    }
    Navigator.pop(context);
    customToast(context,'Category has been deleted');
  }

  Platform.isIOS
      ? await iosDialog(
          context,
              'Are you sure you want to delete this category?', 'Delete',
          onDeletion)
      : await androidDialog(context,  'Are you sure you want to delete this category?', 'Delete',onDeletion);
}
