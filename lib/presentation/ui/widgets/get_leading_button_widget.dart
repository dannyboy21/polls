import 'package:flutter/material.dart';

Widget getLeadingButton(
  context, {
  bool iconClose = false,
  bool isSecureExit = true,
  Color color = Colors.black,
  bool returnWhenPressBack = true,
}) {
  return IconButton(
    onPressed: () async {
      if (!isSecureExit) {
        if (await askForSecureExit(context) == true) {
          Navigator.maybePop(context);
        }
        return;
      }
      Navigator.maybePop(context, returnWhenPressBack);
    },
    iconSize: 22,
    icon: const BackButton(
        //color: Colors.black,
        ),
  );
}

Future<bool?> askForSecureExit(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Cambios sin guardar'),
      content: const Text(
          '¿Deseas salir sin guardar los cambios? Todo los cambios se perderán'),
      actions: [
        TextButton(
          child: const Text('Sí, deseo salir.'),
          onPressed: () => Navigator.pop(c, true),
        ),
        TextButton(
          child: const Text('No'),
          onPressed: () => Navigator.pop(c, false),
        ),
      ],
    ),
  );
}

PreferredSize getBottomAppBar(context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(75),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 10.0),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          //color: Colors.black,
        ),
      ),
    ),
    // styleTextTitle
  );
}

PreferredSize getAccountBottomAppBar(context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(55),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 10.0),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
    ),
    // styleTextTitle
  );
}

PreferredSize getBottomAppBarWithEventTitle(
    context, String title, String subtitle) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 20.0, bottom: 8.0, top: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    //color: Colors.black,
                  ),
                ),
                Text(
                  " ($subtitle)",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    //color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
            /*Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ProviderSalesHistoryPage())));
                },
                label: const Text(
                  "Pedidos",
                  style: TextStyle(
                    color: Color(0xff04d119),
                  ),
                ),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: Color(0xff04d119),
                ),
              ),
            )*/
          ],
        )),
    // styleTextTitle
  );
}

PreferredSize bottomTitle(context, String title,
    {double fontSize = 24, bool isLoading = false}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50), // 30
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              maxLines: 4,
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black),
            ),
          ),
          isLoading
              ? const Padding(
                  padding: EdgeInsets.only(left: 15, right: 20),
                  child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator()),
                )
              : Container(),
        ],
      ),
    ),
  );
}
