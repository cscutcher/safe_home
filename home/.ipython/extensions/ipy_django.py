# -*- coding: utf-8 -*-
'''
IPython Extension for Django helpers.
'''
from __future__ import print_function
import logging
import json

from IPython.core import magic

try:
    from django.core.serializers import serialize as django_serialize
except ImportError:
    django_serialize = None

DEV_LOGGER = logging.getLogger(__name__)


@magic.magics_class
class DjangoReprMagics(magic.Magics):
    '''
    Manage pretty printing Django objects and the config options for that.
    '''
    def __init__(self, *args, **kwargs):
        super(DjangoReprMagics, self).__init__(*args, **kwargs)
        self.use_dict_for_model_output = False

    @magic.line_magic
    def django_dict_for_model_output(self, line):
        '''
        Toggle whether we use dict or serializer for prettification.
        '''
        line = line.strip().lower()
        if not line:
            self.use_dict_for_model_output = not self.use_dict_for_model_output
        elif line in ('1', 'yes', 'true'):
            self.use_dict_for_model_output = True
        elif line in ('0', 'no' 'false'):
            self.use_dict_for_model_output = False
        else:
            raise ValueError('Unexpected: ' + line)

        if self.use_dict_for_model_output:
            print('Using dict for Django model output.')
        else:
            print('Using serializer for Django model output.')

    def repr_model_sequence(self, inst, p, cycle):
        '''
        Format a sequence of models.
        '''
        if cycle:
            raise NotImplementedError('Cycle detected.')

        if self.use_dict_for_model_output:
            p.pretty([m for m in inst])
        else:
            p.pretty(json.loads(django_serialize('json', inst)))

    def repr_model(self, inst, p, cycle):
        '''
        Format Django model nicely
        '''
        if cycle:
            raise NotImplementedError('Cycle detected.')

        if self.use_dict_for_model_output:
            p.pretty(inst.__dict__)
        else:
            inst, = json.loads(django_serialize('json', [inst]))
            p.pretty(inst)


def load_ipython_extension(ipython):
    ''' Load extension. '''
    django_repr_magic = DjangoReprMagics(ipython)
    ipython.register_magics(django_repr_magic)
    try:
        from django.db.models.query import QuerySet
    except ImportError:
        pass
    else:
        ipython.display_formatter.formatters['text/plain'].for_type(
            QuerySet, django_repr_magic.repr_model_sequence)
    try:
        from django.db.models.base import Model
    except ImportError:
        pass
    else:
        ipython.display_formatter.formatters['text/plain'].for_type(
            Model, django_repr_magic.repr_model)
