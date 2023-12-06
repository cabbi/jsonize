## 1.7.2+1
 - Warnings removal

## 1.7.2
- Fixed 'ClonableAsyncInterface' by setting 'beforeDecodeEx' and 'afterDecodeEx' as futures and waiting on 'fromJsonAsync'

## 1.7.1
- Fixed issue with 'ClonableAsyncMixin' not recognized as 'ClonableAsync' when deserializing
  
## 1.7.0

- Introduced mixin classes for 'Clonable', 'ClonableEx' and 'ClonableAsync' interfaces in order to use clonable interfaces without overriding classes (i.e. use 'with' instead of 'extends').

## 1.6.2

- Improved 'ClonableAsync' interface now awaiting class members assignment.

## 1.6.1

- Added 'awaitNestedFutures' parameter in 'fromJson' method.
- README file update

## 1.6.0

- Added 'ClonableEx' and 'ClonableAsync' interfaces to handle external parameter and async serialization

## 1.5.0

- Added 'Duration' support with 'DurationFormat'

## 1.4.3

- Fix on generic classes register

## 1.4.2

- Added support for registering generic classes

## 1.4.1

- Added 'unknownEnumValue' parameter to 'registerEnum' to handle unrecognized json values
- Assigned default getter & setter to 'CloneField' instance  

## 1.4.0

- Added 'enhanced enums' handling (new in dart 2.17 release) using the 'JsonizableEnum' interface.

## 1.3.0

- Added enum serialization via 'registerEnum'
- Added 'Clonable' interface to simplify the definition of a Jsonizable class.  
- Modified the 'CallbackFunction' prototype by adding the object as last parameter

## 1.2.0

- Added 'convertCallback' to the 'toJson' and 'fromJson' methods to enable custom transformation of the object json representation.

## 1.1.0

- Changed the 'indent' from positional to named parameter in the 'toJson' method (this breaks compatibility with previous version).
- Now you can set a custom 'jsonClassToken' when convert to and from json.
- Now you can set a custom 'dtClassToken' (i.e. DateTime object class token) when convert to and from json.
- Now you can set a custom 'dateTimeFormat' (i.e. DateTimeFormat enum) to serialize DateTime objects in different ways with different precisions.
- Added JsonizeException class. Each possible exception thrown by jsonize package is of that type.

## 1.0.1

- Added examples.

## 1.0.0

- Initial version.
