---
layout: post
title: A java function that lists an object's field names
date: '2021-08-17 08:07:46 +0200'
comments: true
today:
  type: wrote
categories: programming
tags: java reflection
versions:
  java: 16.0.2
---

In order to make some assertions in a Java project's automated test suite, I
needed to get the list of private, protected and public members of an object.

Using
[`Class#getDeclaredFieldNames()`](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/lang/Class.html#getDeclaredFields()),
you can easily get a class's
[`Field`](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/lang/reflect/Field.html)s,
an example of [reflection in Java](https://www.baeldung.com/java-reflection):

```java
Class<?> someClass = someObject.getClass();
Field[] declaredFields = someClass.getDeclaredFields();
```

For our purposes, we'll get that as a
[stream](https://docs.oracle.com/en/java/javase/16/docs/api/java.base/java/util/stream/package-summary.html):

```java
Stream<Field> declaredFields = Arrays.stream(
  someClass.getDeclaredFields()
);
```

Unfortunately, this only returns the class's direct fields. It doesn't include
fields from parent classes. But we can do that with a [recursive
function](https://en.wikipedia.org/wiki/Recursion_(computer_science)):

```java
package com.alphahydrae.example;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.stream.Stream;

public final class FieldUtils {

  public static Stream<Field> streamFields(
    Class<?> currentClass
  ) {
    // The stop condition for the recursive function: when we
    // run out of parent classes, return an empty stream.
    if (currentClass == null) {
      return Stream.empty();
    }

    // Return the stream of the parent class's fields
    // concatenated to the current class's.
    return Stream.concat(
      streamFields(currentClass.getSuperclass()),
      Arrays.stream(currentClass.getDeclaredFields())
    );
  }

  private FieldUtils() {}
}
```

Using the functional powers granted to us by streams, we can easily:

* Filter out the fields we don't want (in this case I did not want static fields
  to be listed);
* Get the names of the fields.

```java
// ...
import java.lang.reflect.Modifier;
import java.util.List;
import java.util.stream.Collectors;

public final class FieldUtils {
  // ...

  public static List<String> getDeclaredFieldNames(
    Object object
  ) {
    return getFields(object.getClass())
      // Filter out static fields.
      .filter(field ->
        !Modifier.isStatic(field.getModifiers()))
      // Get the names.
      .map(Field::getName)
      // Collect them into a list.
      .collect(Collectors.toList());
  }

  // ...
}
```

Done.

Here's how you could use it:

```java
// PersonDto.java
public class PersonDto {
  public String firstName;
  public String lastName;
}

// EmployeeDto.java
public class EmployeeDto extends PersonDto {
  public String employeeNo;
}

// EmployeeDtoTests.java
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsInAnyOrder;
import org.junit.jupiter.api.Test;

public class EmployeeDtoTests {

  @Test
  void employeeDtoFieldsHaveNotChanged() {
    assertThat(
      FieldUtils.getDeclaredFieldNames(new EmployeeDto()),
      containsInAnyOrder(
        "firstName",
        "lastName",
        "employeeNo"
      )
    );
  }
}
```
