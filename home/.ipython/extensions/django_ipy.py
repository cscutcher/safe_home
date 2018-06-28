# -*- coding: utf-8 -*-
'''
IPython Extension for Django helpers.

TODO: Properly override the standard IPython pretty.
'''
from collections import Mapping
from collections import Iterable
import logging
import json

from django.db.models.query import QuerySet
from django.db.models.base import ModelState
from django.core.serializers import serialize as django_serialize
import six

DEV_LOGGER = logging.getLogger(__name__)


class DjangoBaseSerializer:
    def __call__(self, inst):
        if (
                getattr(inst, '__metaclass__', None) and
                inst.__metaclass__.__name__ == 'ModelBase'):
            return self._serialize_model(inst)
        elif hasattr(inst, '_state') and isinstance(inst._state, ModelState):
            return self._serialize_model(inst)
        # Catch any Django QuerySets that might get passed in
        elif isinstance(inst, QuerySet):
            return self._serialize_iterable(inst)
        elif isinstance(inst, Mapping):
            print('map')
            inst = {k: self(v) for k, v in six.iteritems(inst)}
        elif isinstance(inst, six.string_types):
            return inst
        elif isinstance(inst, Iterable):
            return self._serialize_iterable(inst)
        return inst

    @classmethod
    def _serialize_mapping(cls, inst):
        return {
            k: cls(v) for k, v in six.iteritems(inst)}


class DjangoAwareSerializer(DjangoBaseSerializer):
    @staticmethod
    def _serialize_model(inst):
        s, = json.loads(django_serialize('json', (inst,)))
        return s

    @staticmethod
    def _serialize_iterable(inst):
        return json.loads(django_serialize('json', inst))


class DjangoDictSerializer(DjangoBaseSerializer):
    @staticmethod
    def _serialize_model(inst):
        return inst.__dict__

    def _serialize_iterable(self, inst):
        return [self(i) for i in inst]


def dprint(inst, use_django_serializer=True):
    '''
    Method that takes Django objects and containers of Django objects and
    serializes them to something that ipython can pretty print.

    :param use_django_serializer:
        If True (default) than Django's built in serialize code is used to
        convert models and QuerySet.
        Otherwise just extract the `__dict__` from models and use that.

    :returns:
        Almost anything. In worst case exactly what was passed in.
        It's a best effort to convert to the most prettifiable objects
        available.
    '''
    if use_django_serializer:
        cls = DjangoAwareSerializer
    else:
        cls = DjangoDictSerializer

    return cls()(inst)


def load_ipython_extension(ipython):
    ipython.push({'dprint': dprint})
