import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert{

  static void dialogue(BuildContext context, String title, String content,double? height){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Theme.of(context).cardColor,
            title: Text(title,style: Theme.of(context).textTheme.titleMedium,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height ?? 5,),
                Text(content,style: Theme.of(context).textTheme.bodyMedium,),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Okay',style: Theme.of(context).textTheme.labelLarge,)
              )
            ],
          );
        }
    );
  }

}