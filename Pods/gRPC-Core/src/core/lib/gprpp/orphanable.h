/*
 *
 * Copyright 2017 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#ifndef GRPC_CORE_LIB_GPRPP_ORPHANABLE_H
#define GRPC_CORE_LIB_GPRPP_ORPHANABLE_H

#include <grpc/support/port_platform.h>

#include <grpc/support/log.h>
#include <grpc/support/sync.h>

#include <cinttypes>
#include <memory>

#include "src/core/lib/debug/trace.h"
#include "src/core/lib/gprpp/abstract.h"
#include "src/core/lib/gprpp/debug_location.h"
#include "src/core/lib/gprpp/memory.h"
#include "src/core/lib/gprpp/ref_counted.h"
#include "src/core/lib/gprpp/ref_counted_ptr.h"

namespace grpc_core {

// A base class for orphanable objects, which have one external owner
// but are not necessarily destroyed immediately when the external owner
// gives up ownership.  Instead, the owner calls the object's Orphan()
// method, and the object then takes responsibility for its own cleanup
// and destruction.
class Orphanable {
 public:
  // Gives up ownership of the object.  The implementation must arrange
  // to eventually destroy the object without further interaction from the
  // caller.
  virtual void Orphan() GRPC_ABSTRACT;

  // Not copyable or movable.
  Orphanable(const Orphanable&) = delete;
  Orphanable& operator=(const Orphanable&) = delete;

  GRPC_ABSTRACT_BASE_CLASS

 protected:
  Orphanable() {}
  virtual ~Orphanable() {}
};

template <typename T>
class OrphanableDelete {
 public:
  void operator()(T* p) { p->Orphan(); }
};

template <typename T, typename Deleter = OrphanableDelete<T>>
using OrphanablePtr = std::unique_ptr<T, Deleter>;

template <typename T, typename... Args>
inline OrphanablePtr<T> MakeOrphanable(Args&&... args) {
  return OrphanablePtr<T>(New<T>(std::forward<Args>(args)...));
}

// A type of Orphanable with internal ref-counting.
template <typename Child>
class InternallyRefCounted : public Orphanable {
 public:
  // Not copyable nor movable.
  InternallyRefCounted(const InternallyRefCounted&) = delete;
  InternallyRefCounted& operator=(const InternallyRefCounted&) = delete;

  GRPC_ABSTRACT_BASE_CLASS

 protected:
  GPRC_ALLOW_CLASS_TO_USE_NON_PUBLIC_DELETE

  // Allow RefCountedPtr<> to access Unref() and IncrementRefCount().
  template <typename T>
  friend class RefCountedPtr;

  // TraceFlagT is defined to accept both DebugOnlyTraceFlag and TraceFlag.
  // Note: RefCount tracing is only enabled on debug builds, even when a
  //       TraceFlag is used.
  template <typename TraceFlagT = TraceFlag>
  explicit InternallyRefCounted(TraceFlagT* trace_flag = nullptr)
      : refs_(1, trace_flag) {}
  virtual ~InternallyRefCounted() = default;

  RefCountedPtr<Child> Ref() GRPC_MUST_USE_RESULT {
    IncrementRefCount();
    return RefCountedPtr<Child>(static_cast<Child*>(this));
  }
  RefCountedPtr<Child> Ref(const DebugLocation& location,
                           const char* reason) GRPC_MUST_USE_RESULT {
    IncrementRefCount(location, reason);
    return RefCountedPtr<Child>(static_cast<Child*>(this));
  }

  void Unref() {
    if (refs_.Unref()) {
      Delete(static_cast<Child*>(this));
    }
  }
  void Unref(const DebugLocation& location, const char* reason) {
    if (refs_.Unref(location, reason)) {
      Delete(static_cast<Child*>(this));
    }
  }

 private:
  void IncrementRefCount() { refs_.Ref(); }
  void IncrementRefCount(const DebugLocation& location, const char* reason) {
    refs_.Ref(location, reason);
  }

  grpc_core::RefCount refs_;
};

}  // namespace grpc_core

#endif /* GRPC_CORE_LIB_GPRPP_ORPHANABLE_H */
