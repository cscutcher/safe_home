# -*- coding: utf-8 -*-
'''
IPython Extension for Django helpers.
'''
import logging

from IPython.lib.pretty import pretty
from django.db.models.query import QuerySet

DEV_LOGGER = logging.getLogger(__name__)


def dprint(object, stream=None, indent=1, width=80, depth=None):
    """
    A small addition to pprint that converts any Django model objects to
    dictionaries so they print prettier.

    h3. Example usage

        >>> from toolbox.dprint import dprint
        >>> from app.models import Dummy
        >>> dprint(Dummy.objects.all().latest())
         {'first_name': u'Ben',
          'last_name': u'Welsh',
          'city': u'Los Angeles',
          'slug': u'ben-welsh',
    """
    # Catch any singleton Django model object that might get passed in
    if getattr(object, '__metaclass__', None):
        if object.__metaclass__.__name__ == 'ModelBase':
            # Convert it to a dictionary
            object = object.__dict__

    # Catch any Django QuerySets that might get passed in
    elif isinstance(object, QuerySet):
        # Convert it to a list of dictionaries
        object = [i.__dict__ for i in object]
    else:
        try:
            it = iter(object)
        except TypeError:
            pass
        else:
            object = [i.__dict__ for i in it]

    return pretty(object)


def load_ipython_extension(ipython):
    ipython.dprint = dprint
