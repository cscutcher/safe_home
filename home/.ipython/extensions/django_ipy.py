# -*- coding: utf-8 -*-
'''
IPython Extension for Django helpers.
'''
from collections import Mapping
from collections import Iterable
import logging

from IPython.lib.pretty import pretty
from django.db.models.query import QuerySet
import six

DEV_LOGGER = logging.getLogger(__name__)


def dprint(inst, stream=None, indent=1, width=80, depth=None):
    """
    A small addition to pprint that converts any Django model object to
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
    if getattr(inst, '__metaclass__', None):
        if inst.__metaclass__.__name__ == 'ModelBase':
            # Convert it to a dictionary
            inst = inst.__dict__

    # Catch any Django QuerySets that might get passed in
    elif isinstance(inst, QuerySet):
        # Convert it to a list of dictionaries
        inst = [i.__dict__ for i in inst]
    elif isinstance(inst, Mapping):
        inst = {k: pretty(v) for k, v in six.iteritems(inst)}
    elif isinstance(inst, six.string_types):
        pass
    elif isinstance(inst, Iterable):
        inst = [pretty(i) for i in inst]

    return pretty(inst)


def load_ipython_extension(ipython):
    ipython.dprint = dprint
