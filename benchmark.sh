#!/bin/bash

prepare_environment() {
  declare -g log_to_filesystem=true
  declare -g automl='imbaml'
  declare -g metrics=('f1')
  #  declare imba_search_space='all'

  # TODO: check for flags for comparison.
  if [[ "$*" == *"-c"* ]]; then
    unset log_to_filesystem
  fi

  case "$*" in
    *"-ag"*)
      automl="ag"

      if [[ "$*" != *"-test"* ]]; then
        declare -g autogluon_preset='good_quality'
      else
        declare -g autogluon_preset='medium_quality'
      fi
      ;;
    *"-flaml"*)
      automl="flaml"
      ;;
  esac

  case "$*" in
    *"-acc"*)
      metrics[0]="balanced_accuracy"
      ;;
    *"-rec"*)
      metrics[0]="recall"
      ;;
    *"-pr"*)
      metrics[0]="precision"
      ;;
    *"-ap"*)
      metrics[0]="average_precision"
      ;;
  esac

  if [[ "$*" != *"-test"* || $automl != 'imbaml' ]]; then
    unset sanity_check
  fi

  source venv/bin/activate
}

run_on_cloud() {
  prepare_environment "$@"

  datasphere project job execute -p bt11vja833cag6o9vusf -c cloud.yaml &
}

run_locally() {
  prepare_environment "$@"

  "$VIRTUAL_ENV"/bin/python -m experiment.main\
  --automl="$automl"\
  --log_to_filesystem="$log_to_filesystem"\
  --autogluon_preset="$autogluon_preset"\
  --metrics="${metrics[*]}"\
  --sanity_check="$sanity_check"
}

if [[ "$*" == *"-cloud"* ]]; then
  run_on_cloud "$@"
else
  run_locally "$@"
fi


