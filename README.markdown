DejalIntervalPicker
===================

DejalIntervalPicker is a custom Mac control similar to NSDatePicker, but for time intervals or ranges.

![DejalIntervalPicker Demo app, showing a drop-down menu for the units](http://www.dejal.com/developer/dejalintervalpicker/overview.png)

![Some other examples of interval pickers](http://www.dejal.com/developer/dejalintervalpicker/icon.png)


Donations
---------

I wrote DejalIntervalPicker for my own use, but I'm making it available for the benefit of the Mac developer community.

If you find it useful, a donation via PayPal (or something from my Amazon.com Wish List) would be very much appreciated. Appropriate links can be found on the Dejal Developer page:

<http://www.dejal.com/developer>


Latest Version
--------------

You can find the latest version of this code via the GitHub repository:

<https://github.com/Dejal/DejalIntervalPicker>

For news on updates, also check out the Dejal Developer page or the Dejal Blog filtered for DejalIntervalPicker posts:

<http://www.dejal.com/blog/dejalintervalpicker>


Requirements
------------

- OS X 10.10 or later recommended, but should work back to 10.7.
- Objective-C language.
- ARC.
- Dependency: the [DejalObject](https://github.com/Dejal/DejalObject) project.


Features
--------

- A custom control with an amount or amount range, units, and stepper.
- Like `NSDatePicker`, editing components separately, with a stepper.
- Can set minimum and maximum amounts.
- Can get/set the interval as a `DejalInterval`, as individual values, or as a `NSTimeInterval`.
- Can have either a single amount or a range of amounts.
- Can optionally filter the range to ensure the first amount is smaller (or equal to) the second one, or vice versa.
- Can control which units to include.
- Can navigate between components via Tab and Shift-Tab and left/right arrow keys, or clicking.
- Can type amounts just like in the date picker, and units with auto-completion.
- Can increment and decrement amounts and units via up/down arrow keys, +/- keys, or the stepper.
- Can increment/decrement in steps of 5 via Shift/Option/Ctrl and up/down arrow keys, or Page Up/Down.
- Can go to the first/last valid values via Home/End.
- Can display a drop-down menu of suggested legal amounts or units via the spacebar or clicking on the selected value.
- Supports regular, small and mini sizes.
- Supports properties, key-value coding, and bindings.
- Supports `IB_DESIGNABLE` and `IBInspectable`, so the picker can be configured in IB.
- A demo project is included.


Usage
-----

1. Include the DejalIntervalPicker.h and DejalIntervalPicker.m files in your project.  Also include at least DejalObject.h, DejalObject.m, DejalInterval.h and DejalInterval.m from the [DejalObject](https://github.com/Dejal/DejalObject) project.
2. In Interface Builder for your xib or storyboard, drag a custom view to your view or window.
3. In the **Identity** inspector, change the **Custom Class** of the view to `DejalIntervalPicker`.
4. In the **Size** inspector, add a **Placeholder Intrinsic Size** of 150 width and 22 height if using Auto Layout, or set the view to that size for auto-resizing.
5. In the **Attributes**, configure the desired attributes like the using range, initial amounts, and which units to include.
6. In your controller, you can also configure the picker via methods like `usingRange`, `includeForever`, `firstAmount`, and others; see the demo project for examples.
7. Populate the picker value by setting the amount(s) and units, or setting the `interval` from a `DejalInterval` instance.
8. Get the picker value via the same properties: either amounts(s) and units directly, or the `interval` instance.
9. See `DejalInterval` for several useful methods and properties, e.g. to get a string representation of the interval.


Future Changes
--------------

- Currently the picker uses cells; should change it to avoid that, since Apple plans to deprecate cells in a future OS version.


License and Warranty
--------------------

This code uses the standard BSD license.  See the included License.txt file.  Please also see the [Dejal Open Source License](http://www.dejal.com/developer/license/) web page for more information.

You can use this code at no cost, with attribution.  A non-attribution license is also available, for a fee.

You're welcome to use it in commercial, closed-source, open source, free or any other kind of software, as long as you credit Dejal appropriately.

The placement and format of the credit is up to you, but I prefer the credit to be in the software's "About" window or view, if any. Alternatively, you could put the credit in the software's documentation, or on the web page for the product. The suggested format for the attribution is:

> Includes DejalIntervalPicker code from [Dejal](http://www.dejal.com/developer/).

Where possible, please link the text "Dejal" to the Dejal Developer web page, or include the page's URL: <http://www.dejal.com/developer/>.

This code comes with no warranty of any kind.  I hope it'll be useful to you, but I make no guarantees regarding its functionality or otherwise.


Support / Contact / Bugs / Features
-----------------------------------

I can't promise to answer questions about how to use the code.

If you create an app that uses the code, please tell me about it.

If you want to submit a feature request or bug report, please use [GitHub's issue tracker for this project](https://github.com/Dejal/DejalIntervalPicker/issues).  Or preferably fork the code and implement the feature/fix yourself, then submit a pull request.

Enjoy!

David Sinclair  
Dejal Systems, LLC


Contact: <http://www.dejal.com/contact/?subject=DejalIntervalPicker>
More open source projects: <http://www.dejal.com/developer>
Open source announcements on Twitter: <http://twitter.com/dejalopen>
General Dejal news on Twitter: <http://twitter.com/dejal>

